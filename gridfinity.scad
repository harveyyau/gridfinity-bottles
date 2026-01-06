/*
 * Gridfinity Cylinder Holder Generator
 * 
 * A parametric OpenSCAD model for creating Gridfinity-compatible trays
 * that hold cylindrical objects (bottles, jars, etc.)
 *
 * Features:
 *   - Automatic optimal packing (hex or grid)
 *   - Optional tray walls for lifting
 *   - Optional raised floor
 *   - Stacking support
 *   - Full Gridfinity base compatibility
 */

// ============================================================================
// USER PARAMETERS (Customizer)
// ============================================================================

/* [Grid Size] */
// Number of gridfinity units along X-axis
gridx = 2; // [1:0.5:8]
// Number of gridfinity units along Y-axis
gridy = 2; // [1:0.5:8]

/* [Cylinder Holders] */
// Diameter of cylinders to hold (add ~0.5mm for clearance)
cylinder_diameter = 26; // [10:1:100]
// Height of holder rim above the base
holder_rim_height = 15; // [5:1:50]
// Thickness of rim wall around each holder
holder_rim_thickness = 1.5; // [0.5:0.25:4]
// Extra taper at base of rim for strength
holder_rim_taper = 1; // [0:0.5:3]
// Depth of holder recess into base (0 = flush with baseplate top)
holder_recess_depth = 0.9; // [0:0.1:3]

/* [Tessellation] */
// Packing mode: auto finds optimal arrangement
packing_mode = "auto"; // [auto, grid]
// Clearance between holders (for fit tolerance)
holder_clearance = 0.5; // [0:0.25:2]
// Minimum wall between holders (0 = holders can touch)
min_wall_between = 0; // [0:0.5:5]

/* [Tray Wall] */
// Add outer wall around the tray
enable_tray_wall = false;
// Wall height from base floor (set to match bottle height)
tray_wall_height = 25; // [5:5:150]
// Wall thickness
tray_wall_thickness = 2.0; // [1:0.5:4]
// Add stacking interface (allows trays to stack)
enable_stacking = false;

/* [Raised Floor] */
// Fill empty space between holders with raised floor
enable_raised_floor = false;
// Height of raised floor (from baseplate top)
raised_floor_height = 8; // [1:1:30]

/* [Base Hole Options] */
// Only cut magnet/screw holes at corners
only_corners = false;
// Use gridfinity refined hole style (not compatible with magnet_holes)
refined_holes = false;
// Add holes for 6mm x 2mm magnets
magnet_holes = false;
// Add holes for M3 screws
screw_holes = false;
// Add crush ribs to hold magnets
crush_ribs = true;
// Add chamfer to ease insertion
chamfer_holes = true;

/* [Hidden] */
// Render quality (higher = smoother but slower)
$fa = 15;
$fs = 2;

// ============================================================================
// GRIDFINITY CONSTANTS (Standard Specification)
// ============================================================================

// Grid dimensions
GRID_PITCH = 42;           // Center-to-center distance between grid units
GRID_UNIT_SIZE = 41.5;     // Size of individual base unit
GRID_GAP = GRID_PITCH - GRID_UNIT_SIZE;  // 0.5mm gap between units

// Base profile (the characteristic gridfinity "foot")
BASE_CORNER_RADIUS = 3.75; // r_base = 7.5/2
BASE_PROFILE = [
    [0, 0],
    [0.8, 0.8],
    [0.8, 2.6],      // 0.8 + 1.8
    [2.95, 4.75],    // 0.8 + 2.15, 0.8 + 1.8 + 2.15
    [0, 4.75],
    [0, 0]
];
BASE_PROFILE_MAX_X = 2.95;
BASE_PROFILE_MAX_Y = 4.75;  // h_base

// Baseplate dimensions
BASEPLATE_HEIGHT = 6.4;     // bp_h_bot - total height of weighted base
BASEPLATE_LIP_HEIGHT = 5;   // Height of stacking lip

// Hole specifications
MAGNET_HEIGHT = 2;
MAGNET_HOLE_RADIUS = 3.25;  // 6.5/2
SCREW_HOLE_RADIUS = 1.5;    // 3/2
REFINED_HOLE_RADIUS = 2.93; // 5.86/2
HOLE_DISTANCE_FROM_EDGE = 4.8;

// Tolerances
TOLERANCE = 0.01;
LAYER_HEIGHT = 0.2;

// ============================================================================
// DERIVED VALUES (Calculated from parameters)
// ============================================================================

// Total tray dimensions
_total_width = gridx * GRID_PITCH - GRID_GAP;
_total_depth = gridy * GRID_PITCH - GRID_GAP;

// Holder geometry
_holder_radius = cylinder_diameter / 2;
_holder_outer_radius_bottom = _holder_radius + holder_rim_thickness + holder_rim_taper;
_holder_outer_radius_top = _holder_radius + holder_rim_thickness;
_holder_footprint_radius = _holder_outer_radius_bottom;
_holder_total_height = holder_recess_depth + holder_rim_height;
_holder_start_z = BASEPLATE_HEIGHT - holder_recess_depth;

// Spacing and layout
_holder_spacing = cylinder_diameter + holder_clearance + min_wall_between;
_usable_margin = enable_tray_wall ? tray_wall_thickness : 0;
_usable_width = _total_width - _usable_margin * 2;
_usable_depth = _total_depth - _usable_margin * 2;

// Wall dimensions
_wall_inner_width = _total_width - tray_wall_thickness * 2;
_wall_inner_depth = _total_depth - tray_wall_thickness * 2;
_wall_start_z = BASE_PROFILE_MAX_Y;

// Hole options bundle
_hole_options = _bundle_hole_options(refined_holes, magnet_holes, screw_holes, 
                                      crush_ribs, chamfer_holes, false);

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Bundle hole options into a list for passing to modules
function _bundle_hole_options(refined, magnet, screw, ribs, chamfer, printable) =
    [refined, magnet, screw, ribs, chamfer, printable];

// Generate hexagonal pattern positions
function _generate_hex_positions(w, h, spacing, swap_axes, x_off, y_off) =
    let(
        tight = spacing * sqrt(3) / 2,
        col_sp = swap_axes ? tight : spacing,
        row_sp = swap_axes ? spacing : tight,
        cols = ceil(w / col_sp) + 1,
        rows = ceil(h / row_sp) + 1
    )
    [for (r = [0:rows], c = [0:cols])
        let(
            offset = swap_axes 
                ? (c % 2 == 1 ? spacing/2 : 0)
                : (r % 2 == 1 ? spacing/2 : 0),
            x = c * col_sp + (swap_axes ? 0 : offset) + x_off * col_sp,
            y = r * row_sp + (swap_axes ? offset : 0) + y_off * row_sp
        )
        if (x >= 0 && x <= w && y >= 0 && y <= h) [x, y]
    ];

// Find best hex configuration by trying multiple orientations
function _find_best_hex_config(w, h, spacing) =
    let(
        configs = [
            [false, 0, 0], [false, 0.5, 0], [false, 0, 0.5], [false, 0.5, 0.5],
            [true, 0, 0], [true, 0.5, 0], [true, 0, 0.5], [true, 0.5, 0.5]
        ],
        counts = [for (c = configs) 
            len(_generate_hex_positions(w, h, spacing, c[0], c[1], c[2]))
        ],
        max_count = max(counts),
        best_idx = search(max_count, counts)[0]
    )
    configs[best_idx];

// Generate simple grid positions
function _generate_grid_positions(w, h, spacing) =
    let(
        cols = max(1, floor(w / spacing) + 1),
        rows = max(1, floor(h / spacing) + 1)
    )
    [for (r = [0:rows-1], c = [0:cols-1])
        let(x = c * spacing, y = r * spacing)
        if (x <= w && y <= h) [x, y]
    ];

// Center an array of positions within available space
function _center_positions(positions, w, h, edge_dist) =
    len(positions) == 0 ? [] :
    let(
        xs = [for (p = positions) p[0]],
        ys = [for (p = positions) p[1]],
        array_w = max(xs) - min(xs),
        array_h = max(ys) - min(ys),
        off_x = edge_dist + (w - array_w) / 2 - min(xs),
        off_y = edge_dist + (h - array_h) / 2 - min(ys)
    )
    [for (p = positions) [p[0] + off_x, p[1] + off_y]];

// Main function to generate optimal holder positions
function _generate_holder_positions() = 
    let(
        edge_dist = _holder_footprint_radius,
        avail_w = _usable_width - 2 * edge_dist,
        avail_h = _usable_depth - 2 * edge_dist,
        
        grid_pos = _generate_grid_positions(avail_w, avail_h, _holder_spacing),
        best_hex = _find_best_hex_config(avail_w, avail_h, _holder_spacing),
        hex_pos = _generate_hex_positions(avail_w, avail_h, _holder_spacing,
                                          best_hex[0], best_hex[1], best_hex[2]),
        
        // Prefer grid when counts are equal (cleaner look)
        use_hex = packing_mode != "grid" && len(hex_pos) > len(grid_pos),
        selected = use_hex ? hex_pos : grid_pos,
        centered = _center_positions(selected, avail_w, avail_h, edge_dist)
    )
    len(centered) > 0 ? centered : [[_usable_width/2, _usable_depth/2]];

// Pre-calculate positions
_positions = _generate_holder_positions();
_start_offset_x = -(_total_width / 2) + _usable_margin;
_start_offset_y = -(_total_depth / 2) + _usable_margin;

// ============================================================================
// GEOMETRY MODULES
// ============================================================================

/**
 * Creates a rounded rectangle (2D or 3D)
 */
module rounded_rectangle(size, radius, center = false) {
    if (len(size) == 3) {
        linear_extrude(size.z)
        offset(radius)
        square([size.x - radius*2, size.y - radius*2], center = center);
    } else {
        offset(radius)
        square([size.x - radius*2, size.y - radius*2], center = center);
    }
}

/**
 * Creates a single holder rim (tapered cylinder with straight hole)
 */
module holder_rim(inner_r, outer_r_bottom, outer_r_top, height) {
    difference() {
        cylinder(height, outer_r_bottom, outer_r_top);
        translate([0, 0, -0.1])
        cylinder(height + 0.2, inner_r, inner_r);
    }
}

/**
 * Creates all holder rims at their positions
 */
module holder_array() {
    translate([_start_offset_x, _start_offset_y, _holder_start_z])
    for (pos = _positions) {
        translate([pos[0], pos[1], 0])
        holder_rim(_holder_radius, _holder_outer_radius_bottom, 
                   _holder_outer_radius_top, _holder_total_height);
    }
}

/**
 * Creates the raised floor with holes for holders
 */
module raised_floor() {
    floor_height = min(raised_floor_height, holder_rim_height - 1);
    floor_w = enable_tray_wall ? _wall_inner_width - 0.5 : _total_width - 0.5;
    floor_d = enable_tray_wall ? _wall_inner_depth - 0.5 : _total_depth - 0.5;
    cutout_r = _holder_outer_radius_top + 0.2;
    
    difference() {
        translate([0, 0, _holder_start_z + floor_height/2])
        cube([floor_w, floor_d, floor_height], center = true);
        
        translate([_start_offset_x, _start_offset_y, _holder_start_z - 0.1])
        for (pos = _positions) {
            translate([pos[0], pos[1], 0])
            cylinder(floor_height + 0.2, cutout_r, cutout_r);
        }
    }
}

/**
 * Creates the tray wall
 */
module tray_wall() {
    stacking_height = enable_stacking ? BASEPLATE_LIP_HEIGHT : 0;
    wall_height = tray_wall_height + stacking_height;
    inner_r = max(0.1, BASE_CORNER_RADIUS - tray_wall_thickness);
    
    difference() {
        translate([0, 0, _wall_start_z])
        linear_extrude(wall_height)
        difference() {
            offset(BASE_CORNER_RADIUS)
            square([_total_width - BASE_CORNER_RADIUS*2, 
                    _total_depth - BASE_CORNER_RADIUS*2], center = true);
            offset(inner_r)
            square([_wall_inner_width - inner_r*2, 
                    _wall_inner_depth - inner_r*2], center = true);
        }
        
        if (enable_stacking) {
            translate([0, 0, _wall_start_z + wall_height - BASEPLATE_LIP_HEIGHT])
            stacking_receiver_cut(_wall_inner_width + 0.5, _wall_inner_depth + 0.5);
        }
    }
}

/**
 * Creates the stacking receiver channel (cutter)
 */
module stacking_receiver_cut(inner_w, inner_d) {
    ledge_depth = BASE_PROFILE_MAX_X + 0.5;
    ledge_height = BASEPLATE_LIP_HEIGHT + 1;
    inner_r = max(0.1, BASE_CORNER_RADIUS - ledge_depth);
    
    linear_extrude(ledge_height)
    difference() {
        offset(BASE_CORNER_RADIUS)
        square([inner_w - BASE_CORNER_RADIUS*2, inner_d - BASE_CORNER_RADIUS*2], center = true);
        offset(inner_r)
        square([inner_w - ledge_depth*2 - inner_r*2, 
                inner_d - ledge_depth*2 - inner_r*2], center = true);
    }
}

// ============================================================================
// GRIDFINITY BASE MODULES (Standard Library)
// ============================================================================

/**
 * Sweeps a 2D profile around a rounded rectangle path
 */
module sweep_rounded(width, length) {
    half_w = width / 2;
    half_l = length / 2;
    
    // Four sides
    for (angle = [0, 90, 180, 270]) {
        rotate([0, 0, angle])
        translate([angle == 0 || angle == 180 ? half_w : half_l, 0, 0])
        rotate([90, 0, 90])
        linear_extrude(angle == 0 || angle == 180 ? width : length, center = true)
        children();
    }
    
    // Four corners
    for (x = [-1, 1], y = [-1, 1]) {
        translate([x * half_w, y * half_l, 0])
        rotate([0, 0, (x > 0 ? 0 : 180) + (y > 0 ? 0 : (x > 0 ? -90 : 90))])
        rotate_extrude(angle = 90)
        children();
    }
}

/**
 * Creates a single gridfinity base unit
 */
module block_base(hole_opts, off = 0, size = [GRID_UNIT_SIZE, GRID_UNIT_SIZE]) {
    translation_x = BASE_CORNER_RADIUS - BASE_PROFILE_MAX_X;
    profile_size = size - [2*BASE_CORNER_RADIUS, 2*BASE_CORNER_RADIUS];
    bottom_size = profile_size + [2*translation_x, 2*translation_x];
    
    render(convexity = 2)
    difference() {
        union() {
            sweep_rounded(profile_size.x, profile_size.y)
            translate([translation_x, 0, 0])
            polygon(BASE_PROFILE);
            
            linear_extrude(BASE_PROFILE_MAX_Y)
            offset(translation_x)
            square([bottom_size.x, bottom_size.y], center = true);
        }
        
        // Corner holes
        for (a = [0:90:270]) {
            i = sign(cos(a + 1));
            j = sign(sin(a + 1));
            translate([i * (bottom_size.x/2 - HOLE_DISTANCE_FROM_EDGE),
                       j * (bottom_size.y/2 - HOLE_DISTANCE_FROM_EDGE), 0])
            rotate([0, 0, a])
            block_base_hole(hole_opts, off);
        }
    }
}

/**
 * Creates a base hole (magnet, screw, or refined)
 */
module block_base_hole(hole_opts, off = 0) {
    refined = hole_opts[0];
    magnet = hole_opts[1];
    screw = hole_opts[2];
    ribs = hole_opts[3];
    chamfer = hole_opts[4];
    
    if (refined) {
        translate([0, 0, -0.1])
        cylinder(MAGNET_HEIGHT + 0.1, REFINED_HOLE_RADIUS, REFINED_HOLE_RADIUS);
    } else {
        if (magnet) {
            translate([0, 0, -0.1])
            cylinder(MAGNET_HEIGHT + LAYER_HEIGHT*2 + 0.1, 
                     MAGNET_HOLE_RADIUS, MAGNET_HOLE_RADIUS);
        }
        if (screw) {
            translate([0, 0, -0.1])
            cylinder(BASEPLATE_HEIGHT + 0.2, SCREW_HOLE_RADIUS, SCREW_HOLE_RADIUS);
        }
    }
}

/**
 * Creates a linear pattern of children
 */
module pattern_linear(nx, ny, sx, sy) {
    sy_actual = sy <= 0 ? sx : sy;
    translate([-(nx-1)*sx/2, -(ny-1)*sy_actual/2, 0])
    for (i = [1:ceil(nx)], j = [1:ceil(ny)])
        translate([(i-1)*sx, (j-1)*sy_actual, 0])
        children();
}

/**
 * Creates a complete gridfinity base
 */
module gridfinity_base(gx, gy, hole_opts) {
    // Calculate sizes
    grid_count = [gx, gy];
    unit_size = [GRID_UNIT_SIZE, GRID_UNIT_SIZE];
    center_dist = [GRID_PITCH, GRID_PITCH];
    gap = center_dist - unit_size;
    grid_size_mm = [center_dist.x * gx, center_dist.y * gy] - gap;
    
    // Top cap
    translate([0, 0, BASE_PROFILE_MAX_Y - TOLERANCE])
    linear_extrude(2.2)
    offset(BASE_CORNER_RADIUS)
    square([grid_size_mm.x - BASE_CORNER_RADIUS*2, 
            grid_size_mm.y - BASE_CORNER_RADIUS*2], center = true);
    
    // Base units
    pattern_linear(gx, gy, GRID_PITCH, GRID_PITCH)
    block_base(hole_opts, 0, unit_size);
}

// ============================================================================
// MAIN MODEL
// ============================================================================

/**
 * Main module that assembles the complete cylinder holder tray
 */
module cylinder_holder_tray() {
    clip_w = enable_tray_wall ? _wall_inner_width : _total_width;
    clip_d = enable_tray_wall ? _wall_inner_depth : _total_depth;
    
    union() {
        // 1. Gridfinity base (clipped to match wall footprint)
        intersection() {
            gridfinity_base(gridx, gridy, _hole_options);
            
            translate([0, 0, -1])
            linear_extrude(BASE_PROFILE_MAX_Y + 10)
            offset(BASE_CORNER_RADIUS)
            square([_total_width - BASE_CORNER_RADIUS*2, 
                    _total_depth - BASE_CORNER_RADIUS*2], center = true);
        }
        
        // 2. Holder rims (clipped to fit inside wall)
        intersection() {
            holder_array();
            translate([-clip_w/2, -clip_d/2, -1])
            cube([clip_w, clip_d, 300]);
        }
        
        // 3. Raised floor (optional)
        if (enable_raised_floor) {
            raised_floor();
        }
        
        // 4. Tray wall (optional)
        if (enable_tray_wall) {
            tray_wall();
        }
    }
}

// ============================================================================
// RENDER
// ============================================================================

cylinder_holder_tray();
