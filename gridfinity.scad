/*
 * Gridfinity Cylinder Holder Generator
 * 
 * Creates Gridfinity-compatible trays for holding bottles, jars, 
 * paint pots, or any cylindrical objects.
 *
 * HOW TO USE:
 * 1. Measure your cylinder's diameter and height
 * 2. Set cylinder_diameter (add 0.5mm for easy fit)
 * 3. Set object_height to match your cylinder height
 * 4. Adjust grid size to fit your needs
 *
 * Common sizes: Paint pots ~32mm, Spice jars ~45mm, AA battery ~14.5mm
 */

/* [Grid Size] */
// Gridfinity units wide (1 unit = 42mm)
gridx = 2; // [1:0.5:8]
// Gridfinity units deep (1 unit = 42mm)
gridy = 2; // [1:0.5:8]

/* [Cylinder Size] */
// Diameter of your cylinder + 0.5mm clearance
cylinder_diameter = 32; // [10:1:100]
// How tall to make the holder rim (keeps cylinders upright)
holder_rim_height = 15; // [5:1:50]

/* [Outer Wall] */
// Add walls around the tray (for lifting out of drawer)
enable_tray_wall = false;
// Height of your cylinders (wall will be this tall)
object_height = 50; // [5:5:150]
// Wall thickness
tray_wall_thickness = 2.0; // [1:0.5:4]
// Allow trays to stack (adds ~5mm lip on top)
enable_stacking = false;

/* [Raised Floor] */
// Fill gaps between holders with a raised surface
enable_raised_floor = false;
// Floor height (set equal to holder_rim_height for flush surface)
raised_floor_height = 15; // [1:1:30]

/* [Advanced: Holder Details] */
// Wall thickness around each holder
holder_rim_thickness = 1.5; // [0.5:0.25:4]
// Extra width at base of rim (for strength)
holder_rim_taper = 1; // [0:0.5:3]
// How deep holders sink into base (usually leave at 0.9)
holder_recess_depth = 0.9; // [0:0.1:3]

/* [Advanced: Spacing] */
// How cylinders are arranged: auto picks the best fit
packing_mode = "auto"; // [auto, grid]
// Extra gap around each cylinder for fit tolerance
holder_clearance = 0.5; // [0:0.25:2]
// Minimum gap between holders
min_wall_between = 0; // [0:0.5:5]

/* [Advanced: Base Holes] */
// Only add holes at corners (faster print)
only_corners = false;
// Use refined hole style (smoother, not compatible with magnets)
refined_holes = false;
// Add holes for 6mm x 2mm magnets
magnet_holes = false;
// Add holes for M3 screws
screw_holes = false;
// Add crush ribs to grip magnets
crush_ribs = true;
// Chamfer holes for easier insertion
chamfer_holes = true;

/* [Hidden] */
$fa = 4;
$fs = 2;
div_base_x = 1;
div_base_y = 1;
printable_hole_top = false;
hole_options = bundle_hole_options(refined_holes, magnet_holes, screw_holes, crush_ribs, chamfer_holes, printable_hole_top);


// Gridfinity standard: 42mm grid pitch, 41.5mm base size
l_grid = 42;  // Grid pitch (center-to-center distance)
base_size = 41.5;  // Individual base unit size
base_gap = l_grid - base_size;  // 0.5mm gap between bases

// Calculate total grid dimensions (matching gridfinityBase calculation)
// Formula: gridx * l_grid - gap = gridx * 42 - 0.5
total_width = gridx * l_grid - base_gap;
total_depth = gridy * l_grid - base_gap;

// Full bottle footprint radius (bottle + rim + taper)
holder_footprint_radius = (cylinder_diameter / 2) + holder_rim_thickness + holder_rim_taper;

// Usable area for bottle placement (accounting for walls if enabled)
usable_margin = enable_tray_wall ? tray_wall_thickness : 0;
usable_width = total_width - usable_margin * 2;
usable_depth = total_depth - usable_margin * 2;

// Center-to-center spacing between bottles
// Bottle spacing includes clearance and minimum wall between bottles
holder_spacing = cylinder_diameter + holder_clearance + min_wall_between;

// Hexagonal packing row spacing (sqrt(3)/2 ≈ 0.866)
hex_row_spacing = holder_spacing * sqrt(3) / 2;

// Generate hex grid with specific orientation
// swap_axes: if true, tight spacing is horizontal (good for tall containers)
// x_offset, y_offset: shift pattern for optimization (0 to 0.5 range)
function generate_hex_pattern(avail_w, avail_h, spacing, swap_axes, x_off, y_off) =
    let(
        tight = spacing * sqrt(3) / 2,
        col_spacing = swap_axes ? tight : spacing,
        row_spacing = swap_axes ? spacing : tight,
        
        num_cols = ceil(avail_w / col_spacing) + 1,
        num_rows = ceil(avail_h / row_spacing) + 1,
        
        positions = [for (row = [0:num_rows])
                        for (col = [0:num_cols])
                            let(
                                // Hex offset alternates based on axis orientation
                                offset = swap_axes 
                                    ? (col % 2 == 1 ? spacing / 2 : 0)  // Y offset for alternate columns
                                    : (row % 2 == 1 ? spacing / 2 : 0), // X offset for alternate rows
                                x = col * col_spacing + (swap_axes ? 0 : offset) + x_off * col_spacing,
                                y = row * row_spacing + (swap_axes ? offset : 0) + y_off * row_spacing
                            )
                            if (x >= 0 && x <= avail_w && y >= 0 && y <= avail_h)
                                [x, y]
                    ]
    ) positions;

// Try hex configurations and return the best one (optimized - fewer configs)
function find_best_hex_config(avail_w, avail_h, spacing) =
    let(
        // Try both orientations with key offsets only
        configs = [
            [false, 0, 0], [false, 0.5, 0], [false, 0, 0.5], [false, 0.5, 0.5],
            [true, 0, 0], [true, 0.5, 0], [true, 0, 0.5], [true, 0.5, 0.5]
        ],
        counts = [for (c = configs) 
                    len(generate_hex_pattern(avail_w, avail_h, spacing, c[0], c[1], c[2]))
                 ],
        max_count = max(counts),
        best_idx = search(max_count, counts)[0]
    )
    configs[best_idx];

// Generate grid positions
function generate_grid_positions(avail_w, avail_h, spacing) =
    let(
        num_cols = max(1, floor(avail_w / spacing) + 1),
        num_rows = max(1, floor(avail_h / spacing) + 1)
    )
    [for (row = [0:num_rows-1])
        for (col = [0:num_cols-1])
            let(x = col * spacing, y = row * spacing)
            if (x <= avail_w && y <= avail_h) [x, y]
    ];

// Center positions within usable area
function center_positions(positions, avail_w, avail_h, edge_dist) =
    len(positions) == 0 ? [] :
    let(
        xs = [for (p = positions) p[0]],
        ys = [for (p = positions) p[1]],
        min_x = min(xs),
        max_x = max(xs),
        min_y = min(ys),
        max_y = max(ys),
        array_w = max_x - min_x,
        array_h = max_y - min_y,
        off_x = edge_dist + (avail_w - array_w) / 2 - min_x,
        off_y = edge_dist + (avail_h - array_h) / 2 - min_y
    )
    [for (p = positions) [p[0] + off_x, p[1] + off_y]];

// Generate valid bottle positions with optimal packing
function generate_valid_positions() = 
    let(
        min_edge_dist = holder_footprint_radius,
        avail_w = usable_width - 2 * min_edge_dist,
        avail_h = usable_depth - 2 * min_edge_dist,
        
        // Grid positions (preferred when counts are equal)
        grid_positions = generate_grid_positions(avail_w, avail_h, holder_spacing),
        
        // Find best hex configuration
        best_config = find_best_hex_config(avail_w, avail_h, holder_spacing),
        hex_positions = generate_hex_pattern(avail_w, avail_h, holder_spacing, 
                                             best_config[0], best_config[1], best_config[2]),
        
        // Only use hex if it fits MORE bottles (prefer grid when equal)
        use_hex = packing_mode != "grid" && len(hex_positions) > len(grid_positions),
        selected = use_hex ? hex_positions : grid_positions,
        
        centered = center_positions(selected, avail_w, avail_h, min_edge_dist)
    )
    len(centered) > 0 ? centered : [[usable_width/2, usable_depth/2]];



// STANDARD

/* [Hidden] */
r_c1 = 0.8; 
h_bot = 2.2; 
// l_grid defined earlier with other grid dimensions
r_base = 7.5 / 2; 
TOLLERANCE = 0.01; 
LAYER_HEIGHT = 0.2;
MAGNET_HEIGHT = 2; 
SCREW_HOLE_RADIUS = 3 / 2;
MAGNET_HOLE_RADIUS = 6.5 / 2;
MAGNET_HOLE_DEPTH = MAGNET_HEIGHT + (LAYER_HEIGHT * 2); 
d_hole_from_side=8; 
HOLE_DISTANCE_FROM_BOTTOM_EDGE = 4.8; 
REFINED_HOLE_RADIUS = 5.86 / 2; 
REFINED_HOLE_HEIGHT = MAGNET_HEIGHT - 0.1; 
REFINED_HOLE_BOTTOM_LAYERS = 2; 
MAGNET_HOLE_CRUSH_RIB_INNER_RADIUS = 5.9 / 2; 
MAGNET_HOLE_CRUSH_RIB_COUNT = 8; 
CHAMFER_ADDITIONAL_RADIUS = 0.8;
CHAMFER_ANGLE = 45; 
BASEPLATE_SCREW_COUNTERSINK_ADDITIONAL_RADIUS = 5/2; 
BASEPLATE_SCREW_COUNTERBORE_RADIUS = 5.5/2; 
BASEPLATE_SCREW_COUNTERBORE_HEIGHT = 3; 
r_f2 = 2.8; 
d_div = 1.2; 
d_wall = 0.95; 
d_clear = 0.25;
d_tabh = 15.85; 
d_tabw = 42; 
a_tab = 36;

d_wall2 = r_base-r_c1-d_clear*sqrt(2);
d_magic = -2*d_clear-2*d_wall+d_div; 

// ****************************************
BASE_OUTSIDE_RADIUS = r_base;  

BASE_PROFILE = [
    [0, 0], // Innermost bottom point
    [0.8, 0.8], // Up and out at a 45 degree angle
    [0.8, (0.8+1.8)], // Straight up
    [(0.8+2.15), (0.8+1.8+2.15)], // Up and out at a 45 degree angle
    [0, (0.8+1.8+2.15)], // Go in to form a solid polygon
    [0, 0] //Back to start
];  
BASE_PROFILE_MAX = BASE_PROFILE[3];  
BASE_SIZE = 41.5;  

h_base = BASE_PROFILE_MAX.y; 

BASEPLATE_OUTSIDE_RADIUS = 8 / 2; 
BASEPLATE_LIP = [
    [0, 0], // Innermost bottom point
    [0.7, 0.7], // Up and out at a 45 degree angle
    [0.7, (0.7+1.8)], // Straight up
    [(0.7+2.15), (0.7+1.8+2.15)], // Up and out at a 45 degree angle
    [(0.7+2.15), 0], // Straight down
    [0, 0] //Back to start
];

BASEPLATE_LIP_HEIGHT = 5;

BASEPLATE_CLEARANCE_HEIGHT = BASEPLATE_LIP_HEIGHT - BASEPLATE_LIP[3].y;
assert(BASEPLATE_CLEARANCE_HEIGHT > 0, "Negative clearance doesn't make sense.");
BASEPLATE_LIP_MAX = [BASEPLATE_LIP[3].x, BASEPLATE_LIP_HEIGHT];

// ****************************************
// Weighted Baseplate
// ****************************************

// Baseplate bottom part height (part added with weigthed=true)
bp_h_bot = 6.4;
// Baseplate bottom cutout rectangle size
bp_cut_size = 21.4;
// Baseplate bottom cutout rectangle depth
bp_cut_depth = 4;
// Baseplate bottom cutout rounded thingy width
bp_rcut_width = 8.5;
// Baseplate bottom cutout rounded thingy left
bp_rcut_length = 4.25;
// Baseplate bottom cutout rounded thingy depth
bp_rcut_depth = 2;

// ****************************************

// radius of cutout for skeletonized baseplate
r_skel = 2;
// minimum baseplate thickness (when skeletonized)
h_skel = 1;

holder_start_z = bp_h_bot - holder_recess_depth;


// Generate validated and centered bottle positions
positions = generate_valid_positions();

// Starting position offset (positions are already centered within usable area)
start_offset_x = -(total_width / 2) + usable_margin;
start_offset_y = -(total_depth / 2) + usable_margin;

// Wall dimensions
wall_inner_width = total_width - tray_wall_thickness * 2;
wall_inner_depth = total_depth - tray_wall_thickness * 2;

union() {
    // Gridfinity base - clipped to match wall footprint for fractional grids
    intersection() {
        gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, hole_options);
        // Clip to wall outer boundary
        translate([0, 0, -1])
        linear_extrude(h_base + 10)
        offset(BASE_OUTSIDE_RADIUS)
        square([total_width - BASE_OUTSIDE_RADIUS * 2, total_depth - BASE_OUTSIDE_RADIUS * 2], center = true);
    }
    
    // Holder rims with holes - only clip these if wall is enabled
    clip_width = enable_tray_wall ? wall_inner_width : total_width;
    clip_depth = enable_tray_wall ? wall_inner_depth : total_depth;
    
    intersection() {
        difference() {
            // Holder rim solids - tapered outer
            translate([start_offset_x, start_offset_y, holder_start_z])
            for (pos = positions)
                translate([pos[0], pos[1], 0])
                cylinder(holder_recess_depth + holder_rim_height, 
                         (cylinder_diameter / 2) + holder_rim_thickness + holder_rim_taper, 
                         (cylinder_diameter / 2) + holder_rim_thickness);
            
            // Cut straight holes through holders
            translate([start_offset_x, start_offset_y, holder_start_z - 0.1])
            for (pos = positions)
                translate([pos[0], pos[1], 0])
                cylinder(holder_recess_depth + holder_rim_height + 0.2, 
                         cylinder_diameter / 2, 
                         cylinder_diameter / 2);
        }
        // Clip holder rims to fit inside wall
        translate([-clip_width/2, -clip_depth/2, -1])
        cube([clip_width, clip_depth, 300]);
    }
    
        // Raised floor to fill empty space between bottles
        if (enable_raised_floor) {
            // Floor height from holder floor (capped to rim height)
            floor_height = min(raised_floor_height, holder_rim_height);
            // Actual holder floor Z (where objects sit, after recess)
            holder_floor_z = holder_start_z + holder_recess_depth;
            
            // Floor dimensions - fit inside wall if enabled
            floor_width = enable_tray_wall ? wall_inner_width : total_width;
            floor_depth = enable_tray_wall ? wall_inner_depth : total_depth;
            
            difference() {
                // Solid floor block - starts at holder floor
                translate([0, 0, holder_floor_z + floor_height / 2])
                cube([floor_width, floor_depth, floor_height], center = true);
                
                // Cut out bottle holes - tapered to match holder rim exactly
                translate([start_offset_x, start_offset_y, holder_floor_z - 0.1])
                for (pos = positions)
                    translate([pos[0], pos[1], 0]) {
                    // Match holder taper: bottom radius includes taper, top doesn't
                    bottom_r = (cylinder_diameter / 2) + holder_rim_thickness + holder_rim_taper;
                    top_r = (cylinder_diameter / 2) + holder_rim_thickness;
                    cylinder(floor_height + 0.2, bottom_r, top_r);
                }
            }
        }
        
        // Tray wall for lifting/stacking
        if (enable_tray_wall) {
            // Wall starts at h_base (gridfinity top) to preserve base interface
            wall_start_z = h_base;
            // Use actual profile height for receiver depth (BASE_PROFILE_MAX.y ≈ 4.75mm)
            receiver_depth = enable_stacking ? BASE_PROFILE_MAX.y + 0.5 : 0;
            // Wall height: reaches object_height above holder floor, plus space for receiver
            wall_height = (holder_start_z - h_base) + object_height + receiver_depth;
            corner_radius = BASE_OUTSIDE_RADIUS;
            stacking_clearance = 0.25;
            
            // Main wall with uniform thickness (use offset for consistent corners)
            difference() {
                translate([0, 0, wall_start_z])
                linear_extrude(wall_height)
                difference() {
                    offset(corner_radius)
                    square([total_width - corner_radius * 2, total_depth - corner_radius * 2], center = true);
                    
                    // Inner cutout - offset inward by wall thickness for uniform walls
                    offset(corner_radius - tray_wall_thickness)
                    square([total_width - corner_radius * 2, total_depth - corner_radius * 2], center = true);
                }
                
                // Cut receiving channel for stacking (pocket for gridfinity feet to fit into)
                if (enable_stacking) {
                    // Cut from the top of the wall, going down
                    translate([0, 0, wall_start_z + wall_height - receiver_depth])
                    stacking_receiver_cut(
                        total_width + stacking_clearance * 2,
                        total_depth + stacking_clearance * 2
                    );
                }
                
            }
            
            // NOTE: stacking_lip_positive removed - we only need the receiver cut
            // The receiver is cut into the wall above (in the difference block)
        }
    }


// ===== Modules ===== //

/**
 * Creates the positive stacking lip using the SAME proven geometry as block_base.
 * This reuses sweep_rounded + BASE_PROFILE for correct gridfinity compatibility.
 */
module stacking_lip_positive(width, depth) {
    // Use the same calculation as block_base for correct profile positioning
    translation_x = BASE_OUTSIDE_RADIUS - BASE_PROFILE_MAX.x;
    profile_size_x = width - 2 * BASE_OUTSIDE_RADIUS;
    profile_size_y = depth - 2 * BASE_OUTSIDE_RADIUS;
    
    // Only create if there's room for the profile
    if (profile_size_x > 0 && profile_size_y > 0) {
        sweep_rounded(profile_size_x, profile_size_y)
        translate([translation_x, 0, 0])
        polygon(BASE_PROFILE);
    }
}

/**
 * Creates the negative (cutter) for the stacking receiver channel.
 * Uses the same BASE_PROFILE but slightly larger for clearance.
 */
module stacking_receiver_cut(inner_width, inner_depth) {
    clearance = 0.3;  // Clearance for the mating profile
    
    // Use same calculation as block_base but with clearance added
    translation_x = BASE_OUTSIDE_RADIUS - BASE_PROFILE_MAX.x;
    profile_size_x = inner_width - 2 * BASE_OUTSIDE_RADIUS;
    profile_size_y = inner_depth - 2 * BASE_OUTSIDE_RADIUS;
    
    // Enlarged profile for clearance
    enlarged_profile = [for (p = BASE_PROFILE) [p.x + clearance, p.y + clearance]];
    
    if (profile_size_x > 0 && profile_size_y > 0) {
        sweep_rounded(profile_size_x, profile_size_y)
        translate([translation_x - clearance, 0, 0])
        polygon(enlarged_profile);
    }
}

module gridfinityBase(gx, gy, length, dx, dy, hole_options=bundle_hole_options(), off=0, final_cut=true, only_corners=false) {
    assert(
        is_num(gx) 
        );
        assert(
        is_num(gy) 
        );
        assert(
        is_num(length) 
        );
        assert(
        is_num(dx) 
        );
        assert(
        is_num(dy) 
        );
        assert(
        is_bool(final_cut) 
        );
        assert(
        is_bool(only_corners) 
        );
    dbnxt = [for (i=[1:5]) if (abs(gx*i)%1 < 0.001 || abs(gx*i)%1 > 0.999) i];
    dbnyt = [for (i=[1:5]) if (abs(gy*i)%1 < 0.001 || abs(gy*i)%1 > 0.999) i];
    dbnx = 1/(dx != 0 ? round(dx) : (len(dbnxt) > 0 ? dbnxt[0] : 1));
    dbny = 1/(dy != 0 ? round(dy) : (len(dbnyt) > 0 ? dbnyt[0] : 1));

    // Final size in number of bases
    grid_size = [gx/dbnx, gy/dbny];

    // Per spec, there's a 0.5mm gap between each base,
    // But that needs to be scaled based on everything else.
    individual_base_size_mm = [dbnx, dbny] * BASE_SIZE;
    base_center_distance_mm = [dbnx, dbny] * length;
    gap_mm = base_center_distance_mm - individual_base_size_mm;

    // Final size of the base top. In mm.
    grid_size_mm = [
        base_center_distance_mm.x * grid_size.x,
        base_center_distance_mm.y * grid_size.y,
    ] - gap_mm;

    if (final_cut) {
        translate([0, 0, h_base-TOLLERANCE])
        rounded_square([grid_size_mm.x, grid_size_mm.y, h_bot], BASE_OUTSIDE_RADIUS, center=true);
    }

    if(only_corners) {
        difference(){
            pattern_linear(grid_size.x, grid_size.y, base_center_distance_mm.x, base_center_distance_mm.y)
            block_base(bundle_hole_options(), 0, individual_base_size_mm);

            copy_mirror([0, 1, 0]) {
                copy_mirror([1, 0, 0]) {
                    translate([
                        grid_size_mm.x/2 - HOLE_DISTANCE_FROM_BOTTOM_EDGE - BASE_PROFILE_MAX.x,
                        grid_size_mm.y/2 - HOLE_DISTANCE_FROM_BOTTOM_EDGE - BASE_PROFILE_MAX.x,
                        0
                    ])
                    block_base_hole(hole_options, off);
                }
            }
        }
    }
    else {
        pattern_linear(grid_size.x, grid_size.y, base_center_distance_mm.x, base_center_distance_mm.y)
        block_base(hole_options, off, individual_base_size_mm);
    }
}

module block_base(hole_options, off=0, size=[BASE_SIZE, BASE_SIZE]) {
    assert(
        is_list(size) &&
        len(size) == 2
    );

    // How far, in the +x direction,
    // the profile needs to be from it's [0, 0] point
    // such that when swept by 90 degrees to produce a corner,
    // the outside edge has the desired radius.
    translation_x = BASE_OUTSIDE_RADIUS - BASE_PROFILE_MAX.x;

    outer_diameter = [2*BASE_OUTSIDE_RADIUS, 2*BASE_OUTSIDE_RADIUS];
    base_profile_size = size - outer_diameter;
    base_bottom_size = base_profile_size + [2*translation_x, 2*translation_x];
    assert(base_profile_size.x > 0 && base_profile_size.y > 0,
        str("Minimum size of a single base must be greater than ", outer_diameter)
    );
    render(convexity = 2)
    difference() {
        union() {
            sweep_rounded(base_profile_size.x, base_profile_size.y)
            translate([translation_x, 0, 0])
            polygon(BASE_PROFILE);

            rounded_square(
                [
                    base_bottom_size.x + TOLLERANCE,
                    base_bottom_size.y + TOLLERANCE,
                    BASE_PROFILE_MAX.y
                ],
                translation_x,
                center=true
            );
        }
        // 4 holes
        // Need this fancy code to support refined holes and non-square bases.
        for(a=[0:90:270]){
            // i and j represent the 4 quadrants.
            // The +1 is used to keep any values from being exactly 0.
            j = sign(sin(a+1));
            i = sign(cos(a+1));
            translate([
                i * (base_bottom_size.x/2 - HOLE_DISTANCE_FROM_BOTTOM_EDGE),
                j * (base_bottom_size.y/2 - HOLE_DISTANCE_FROM_BOTTOM_EDGE),
                0])
            rotate([0, 0, a])
            block_base_hole(hole_options, off);
        }
    }
}

function is_even(number) = (number%2)==0;

module rounded_square(size, radius, center = false) {
    assert(is_num(size) ||
        (is_list(size) && (
            (len(size) == 2 && is_num(size.x) && is_num(size.y)) ||
            (len(size) == 3 && is_num(size.x) && is_num(size.y) && is_num(size.z))
        ))
    );
    assert(is_num(radius) && radius >= 0 && is_bool(center));

    // Make sure something is produced.
    if (is_num(size)) {
        assert((size/2) > radius);
    } else {
        assert((size.x/2) > radius && (size.y/2 > radius));
        if (len(size) == 3) {
            assert(size.z > 0);
        }
    }

    if (is_list(size) && len(size) == 3) {
        linear_extrude(size.z)
        _internal_rounded_square_2d(size, radius, center);
    } else {
        _internal_rounded_square_2d(size, radius, center);
    }
}

module _internal_rounded_square_2d(size, radius, center) {
    diameter = 2*radius;
    if (is_list(size)) {
        offset(radius)
        square([size.x-diameter, size.y-diameter], center = center);
    } else {
        offset(radius)
        square(size-diameter, center = center);
    }
}


module copy_mirror(vec=[0,1,0]) {
    children();
    if (vec != [0,0,0])
    mirror(vec)
    children();
}

module pattern_linear(x = 1, y = 1, sx = 0, sy = 0) {
    yy = sy <= 0 ? sx : sy;
    translate([-(x-1)*sx/2,-(y-1)*yy/2,0])
    for (i = [1:ceil(x)])
    for (j = [1:ceil(y)])
    translate([(i-1)*sx,(j-1)*yy,0])
    children();
}


function vector_magnitude(vector) =
    sqrt(vector.x^2 + vector.y^2 + (len(vector) == 3 ? vector.z^2 : 0));

function vector_as_unit(vector) = vector / vector_magnitude(vector);

function atanv(vector) = atan2(vector.y, vector.x);

function _affine_rotate_x(angle_x) = [
    [1,  0, 0, 0],
    [0, cos(angle_x), -sin(angle_x), 0],
    [0, sin(angle_x), cos(angle_x), 0],
    [0, 0, 0, 1]
];

function _affine_rotate_y(angle_y) = [
    [cos(angle_y),  0, sin(angle_y), 0],
    [0, 1, 0, 0],
    [-sin(angle_y), 0, cos(angle_y), 0],
    [0, 0, 0, 1]
];

function _affine_rotate_z(angle_z) = [
    [cos(angle_z), -sin(angle_z), 0, 0],
    [sin(angle_z), cos(angle_z), 0, 0],
    [0, 0, 1, 0],
    [0, 0, 0, 1]
];

function affine_rotate(angle_vector) =
    _affine_rotate_z(angle_vector.z) * _affine_rotate_y(angle_vector.y) * _affine_rotate_x(angle_vector.x);

function affine_translate(vector) = [
    [1, 0, 0, vector.x],
    [0, 1, 0, vector.y],
    [0, 0, 1, vector.z],
    [0, 0, 0, 1]
];


module sweep_rounded(width=10, length=10) {
    assert(width > 0 && length > 0);

    half_width = width/2;
    half_length = length/2;
    path_points = [
        [-half_width, half_length],  //Start
        [half_width, half_length], // Over
        [half_width, -half_length], //Down
        [-half_width, -half_length], // Back over
        [-half_width, half_length]  // Up to start
    ];
    path_vectors = [
        path_points[1] - path_points[0],
        path_points[2] - path_points[1],
        path_points[3] - path_points[2],
        path_points[4] - path_points[3],
    ];
    // These contain the translations, but not the rotations
    // OpenSCAD requires this hacky for loop to get accumulate to work!
    first_translation = affine_translate([path_points[0].y, 0,path_points[0].x]);
    affine_translations = concat([first_translation], [
        for (i = 0, a = first_translation;
            i < len(path_vectors);
            a=a * affine_translate([path_vectors[i].y, 0, path_vectors[i].x]), i=i+1)
        a * affine_translate([path_vectors[i].y, 0, path_vectors[i].x])
    ]);

    // Bring extrusion to the xy plane
    affine_matrix = affine_rotate([90, 0, 90]);

    walls = [
        for (i = [0 : len(path_vectors) - 1])
        affine_matrix * affine_translations[i]
        * affine_rotate([0, atanv(path_vectors[i]), 0])
    ];

    union()
    {
        for (i = [0 : len(walls) - 1]){
            multmatrix(walls[i])
            linear_extrude(vector_magnitude(path_vectors[i]))
            children();

            // Rounded Corners
            multmatrix(walls[i] * affine_rotate([-90, 0, 0]))
            rotate_extrude(angle = 90, convexity = 4)
            children();
        }
    }
}

function get_fragments_from_r(r) =
    assert(r > 0)
    ($fn>0?($fn>=3?$fn:3):ceil(max(min(360/$fa,r*2*PI/$fs),5)));

function wave_function(t, count, range, vertical_offset) =
    (sin(t * count) * range) + vertical_offset;

module ribbed_circle(outer_radius, inner_radius, ribs) {
    assert(outer_radius > 0, "outer_radius must be positive");
    assert(inner_radius > 0, "inner_radius must be positive");
    assert(ribs > 0, "ribs must be positive");
    assert(outer_radius > inner_radius, "outer_radius must be larger than inner_radius");

    wave_range = (outer_radius - inner_radius) / 2;
    wave_vertical_offset = inner_radius + wave_range;
    fragments=get_fragments_from_r(wave_vertical_offset);
    degrees_per_fragment = 360/fragments;

    // Circe with a wave wrapped around it
    wrapped_circle = [ for (i = [0:degrees_per_fragment:360])
        [sin(i), cos(i)] * wave_function(i, ribs, wave_range, wave_vertical_offset)
    ];

    polygon(wrapped_circle);
}

module ribbed_cylinder(outer_radius, inner_radius, height, ribs) {
    assert(height > 0, "height must be positive");
    linear_extrude(height)
    ribbed_circle(
        outer_radius,
        inner_radius,
        ribs
    );
}

module make_hole_printable(inner_radius, outer_radius, outer_height, layers=2) {
    assert(inner_radius > 0, "inner_radius must be positive");
    assert(outer_radius > 0, "outer_radius must be positive");
    assert(layers > 0);

    tollerance = 0.01;  // Ensure everything is fully removed.
    height_adjustment = outer_height - (layers * LAYER_HEIGHT);

    // Needed, since the last layer should not be used for calculations,
    // unless there is a single layer.
    calculation_layers = max(layers-1, 1);

    cube_height = LAYER_HEIGHT + 2*tollerance;
    inner_diameter = 2*(inner_radius+tollerance);
    outer_diameter = 2*(outer_radius+tollerance);
    per_layer_difference = (outer_diameter-inner_diameter) / calculation_layers;

    initial_matrix = affine_translate([0, 0, cube_height/2-tollerance + height_adjustment]);
    cutout_information = [
        for(i=0; i <= layers; i=i+1)
        [
            initial_matrix * affine_translate([0, 0, (i-1)*LAYER_HEIGHT]) *
                affine_rotate([0, 0, is_even(i) ? 90 : 0]),
            [outer_diameter-per_layer_difference*(i-1),
                outer_diameter-per_layer_difference*i,
                cube_height]
        ]
    ];

    difference() {
        translate([0, 0, layers*cube_height/2 + height_adjustment])
        cube([outer_diameter+tollerance, outer_diameter+tollerance, layers*cube_height], center = true);

        for (i = [1 : calculation_layers]){
            data = cutout_information[i];
            multmatrix(data[0])
            cube(data[1], center = true);
        }
        if(layers > 1) {
            data = cutout_information[len(cutout_information)-1];
            multmatrix(data[0])
            cube([data[1].x, data[1].x, data[1].z], center = true);
        }
    }
}

/**
* @brief Refined hole based on Printables @grizzie17's Gridfinity Refined
* @details Magnet is pushed in from +X direction, and held in by friction.
*          Small slit on the bottom allows removing the magnet.
* @see https://www.printables.com/model/413761-gridfinity-refined
*/
module refined_hole() {
    refined_offset = LAYER_HEIGHT * REFINED_HOLE_BOTTOM_LAYERS;

    // Poke through - For removing a magnet using a toothpick
    ptl = refined_offset + LAYER_HEIGHT; // Additional layer just in case
    poke_through_height = REFINED_HOLE_HEIGHT + ptl;
    poke_hole_radius = 2.5;
    magic_constant = 5.60;
    poke_hole_center = [-12.53 + magic_constant, 0, -ptl];

    translate([0, 0, refined_offset])
    union() {
        // Magnet hole
        translate([0, -REFINED_HOLE_RADIUS, 0])
        cube([11, REFINED_HOLE_RADIUS*2, REFINED_HOLE_HEIGHT]);
        cylinder(REFINED_HOLE_HEIGHT, r=REFINED_HOLE_RADIUS);

        // Poke hole
        translate([poke_hole_center.x, -poke_hole_radius/2, poke_hole_center.z])
        cube([10 - magic_constant, poke_hole_radius, poke_through_height]);
        translate(poke_hole_center)
        cylinder(poke_through_height, d=poke_hole_radius);
    }
}

/**
 * @brief Create a cone given a radius and an angle.
 * @param bottom_radius Radius of the bottom of the cone.
 * @param angle Angle as measured from the bottom of the cone.
 * @param max_height Optional maximum height.  Cone will be cut off if higher.
 */
module cone(bottom_radius, angle, max_height=0) {
    assert(bottom_radius > 0);
    assert(angle > 0 && angle <= 90);
    assert(max_height >=0);

    height = tan(angle) * bottom_radius;
    if(max_height == 0 || height < max_height) {
        // Normal Cone
        cylinder(h = height, r1 = bottom_radius, r2 = 0, center = false);
    } else {
        top_angle = 90 - angle;
        top_radius = bottom_radius - tan(top_angle) * max_height;
        cylinder(h = max_height, r1 = bottom_radius, r2 = top_radius, center = false);
    }
}

/**
 * @brief Create a screw hole
 * @param radius Radius of the hole.
 * @param height Height of the hole.
 * @param supportless If the hole is designed to be printed without supports.
 * @param chamfer_radius If the hole should be chamfered, then how much should be added to radius.  0 means don't chamfer
 * @param chamfer_angle If the hole should be chamfered, then what angle should it be chamfered at.  Ignored if chamfer_radius is 0.
 */
module screw_hole(radius, height, supportless=false, chamfer_radius=0, chamfer_angle = 45) {
    assert(radius > 0);
    assert(height > 0);
    assert(chamfer_radius >= 0);

    union(){
        difference() {
            cylinder(h = height, r = radius);
            if (supportless) {
                rotate([0, 0, 90])
                make_hole_printable(0.5, radius, height, 3);
            }
        }
        if (chamfer_radius > 0) {
            cone(radius + chamfer_radius, chamfer_angle, height);
        }
    }
}

/**
 * @brief Create an options list used to configure bin holes.
 * @param refined_hole Use gridfinity refined hole type.  Not compatible with "magnet_hole".
 * @param magnet_hole Create a hole for a 6mm magnet.
 * @param screw_hole Create a hole for a M3 screw.
 * @param crush_ribs If the magnet hole should have crush ribs for a press fit.
 * @param chamfer Add a chamfer to the magnet/screw hole.
 * @param supportless If the magnet/screw hole should be printed in such a way that the screw hole does not require supports.
 */
function bundle_hole_options(refined_hole=false, magnet_hole=false, screw_hole=false, crush_ribs=false, chamfer=false, supportless=false) =
    assert(
        is_bool(refined_hole) &&
        is_bool(magnet_hole) &&
        is_bool(screw_hole) &&
        is_bool(crush_ribs) &&
        is_bool(chamfer) &&
        is_bool(supportless))
    [refined_hole, magnet_hole, screw_hole, crush_ribs, chamfer, supportless];

/**
 * @summary Ensures that hole options are valid, and can be used.
 */
module assert_hole_options_valid(hole_options) {
    assert(is_list(hole_options) && len(hole_options) == 6);
    for(option=hole_options){
        assert(is_bool(option), "One or more hole options is not a boolean value!");
    }
    refined_hole = hole_options[0];
    magnet_hole = hole_options[1];
    if(refined_hole) {
        assert(!magnet_hole, "magnet_hole is not compatible with refined_hole");
    }
}

/**
 * @brief A single magnet/screw hole.  To be cut out of the base.
 * @details Supports multiple options that can be mixed and matched.
 * @pram hole_options @see bundle_hole_options
 * @param o Offset
 */
module block_base_hole(hole_options, o=0) {
    assert_hole_options_valid(hole_options);
    assert(is_num(o));
    refined_hole = hole_options[0];
    magnet_hole = hole_options[1];
    screw_hole = hole_options[2];
    crush_ribs = hole_options[3];
    chamfer = hole_options[4];
    supportless = hole_options[5];

    screw_radius = SCREW_HOLE_RADIUS - (o/2);
    magnet_radius = MAGNET_HOLE_RADIUS - (o/2);
    magnet_inner_radius = MAGNET_HOLE_CRUSH_RIB_INNER_RADIUS - (o/2);
    screw_depth = h_base-o;
    supportless_additional_layers = screw_hole ? 2 : 3;
    magnet_depth = MAGNET_HOLE_DEPTH - o +
        (supportless ? supportless_additional_layers*LAYER_HEIGHT : 0);

    union() {
        if(refined_hole) {
            refined_hole();
        }

        if(magnet_hole) {
            difference() {
                if(crush_ribs) {
                    ribbed_cylinder(magnet_radius, magnet_inner_radius, magnet_depth, MAGNET_HOLE_CRUSH_RIB_COUNT);
                } else {
                    cylinder(h = magnet_depth, r=magnet_radius);
                }

                if(supportless) {
                    make_hole_printable(
                    screw_hole ? screw_radius : 1, magnet_radius, magnet_depth, supportless_additional_layers);
                }
            }

            if(chamfer) {
                 cone(magnet_radius + CHAMFER_ADDITIONAL_RADIUS, CHAMFER_ANGLE, MAGNET_HOLE_DEPTH - o);
            }
        }
        if(screw_hole) {
            screw_hole(screw_radius, screw_depth, supportless,
                chamfer ? CHAMFER_ADDITIONAL_RADIUS : 0, CHAMFER_ANGLE);
        }
    }
}

if(!is_undef(test_options)){
    block_base_hole(test_options);
}


