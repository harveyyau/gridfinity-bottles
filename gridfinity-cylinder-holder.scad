/*
 * Gridfinity Cylinder Holder with Honeycomb Lattice Walls
 * 
 * Creates customizable Gridfinity-compatible trays for batteries, paint pots,
 * spice jars, or any cylindrical objects. Features beautiful honeycomb 
 * lattice walls that save filament and look great!
 *
 * 🎯 QUICK START:
 * 1. Measure your cylinder diameter with calipers
 * 2. Set "cylinder_diameter" (add 0.5mm for easy fit)
 * 3. Measure your item height and set "object_height"
 * 4. Choose how tray height is specified in "height_mode"
 * 5. Adjust "gridx" and "gridy" for tray size
 * 6. Customize wall pattern (lattice saves 40%+ filament!)
 * 7. Want an empty bin? Set "enable_holders" = false
 *
 * 📏 COMMON SIZES:
 * - AA batteries: 14.5mm diameter × 51mm (default)
 * - AAA batteries: 10.5mm diameter × 45mm
 * - Paint pots: 32mm diameter × 40mm
 * - Spice jars: 45mm diameter × 80mm  
 * - Pill bottles: 25-30mm diameter
 */

/* [Grid Size] */
// Gridfinity units wide (1 unit = 42mm)
gridx = 2; // [0.5:0.5:8]
// Gridfinity units deep (1 unit = 42mm)
gridy = 1; // [0.5:0.5:8]

/* [Item & Holders] */
// Diameter of your cylinders (measured with calipers, add ~0.5mm clearance)
cylinder_diameter = 14.5; // [10:0.1:100]
// Height of your item (mm) — measured end-to-end (used when height_mode="object")
object_height = 51; // [5:1:200]
// Extra clearance for easy fit (0.5mm recommended, increase if too tight)
holder_clearance = 0.5; // [0:0.05:2]
// Height of holder rim that keeps cylinders upright
holder_rim_height = 15; // [5:1:50]
// Generate cylinder holders (holes). Disable for an empty tray/bin (cylinder sizing is ignored).
enable_holders = true;

/* [Height (Z)] */
// How to specify tray height (Z):
// - object: tray fits your object height (optionally snapped to 7mm Gridfinity units)
// - exclude_base: height above base top (7mm = 1u)
// - total: total external height including base (7mm = 1u)
height_mode = "exclude_base"; // [object:Fit item height, exclude_base:Height above base, total:Total external height]
// Extra headroom above the object height when height_mode="object"
object_height_clearance = 1; // [0:0.5:10]
// Snap object-fit height up to next 7mm unit (recommended for Gridfinity)
snap_object_height_to_u = true;
// Height above base top when height_mode="exclude_base" (mm; 7mm = 1u)
height_excluding_base = 28; // [7:7:210]
// Total external height including base when height_mode="total" (mm; 7mm = 1u)
total_height = 35; // [7:7:210]

/* [Tray Walls - Recommended!] */
// Add walls around the tray (great for drawer organization!)
enable_tray_wall = true;
// Wall thickness (2mm is strong and prints well)
tray_wall_thickness = 2.0; // [1.5:0.5:4]
// Use beautiful honeycomb lattice walls (saves 40%+ filament!)
wall_pattern = "lattice"; // [lattice:Honeycomb lattice, solid:Solid]

/* [Lattice Wall Settings] */
// Honeycomb cell size - smaller = more cells, more detail
lattice_cell_size = 8; // [5:1:12]
// Rib thickness between hex holes (1.2-2mm prints reliably)
lattice_rib_thickness = 1.2; // [0.8:0.2:3]
// Solid corners for strength (distance from corner)
lattice_corner_margin = 5; // [3:1:10]
// Solid rim height at bottom (above raised floor if enabled)
lattice_bottom_rim = 3; // [0:1:10]

/* [Advanced: Optional Features] */
// Fill gaps between holders with raised floor (when holders are disabled, this is a solid slab)
enable_raised_floor = true;
// Floor height above holder bottom (set to holder_rim_height for flush top)
raised_floor_height = 16; // [5:1:30]
// Make tray stackable (requires tray walls + Gridfinity base)
enable_stacking = true;
// Stacking fit tolerance - increase if too tight
stacking_clearance = 0.3; // [0.1:0.05:1]
// Alignment ramp length (percentage of side)
stacking_ramp_length_percent = 50; // [20:10:80]

/* [Advanced: Holder Details] */
// Wall thickness around each holder (1.5-3mm recommended)
holder_rim_thickness = 2.0; // [1:0.25:4]
// Extra thickness at base for strength
holder_rim_taper = 1; // [0:0.5:3]
// How deep holders sink into base
holder_recess_depth = 0.9; // [0.5:0.1:2]

/* [Advanced: Packing] */
// Cylinder arrangement (auto optimizes spacing)
packing_mode = "auto"; // [auto:Auto pack, grid:Grid]
// Minimum wall thickness between holders (0.2mm+ recommended for strength and clean geometry)
min_wall_between = 0.2; // [0:0.1:5]

/* [Advanced: Base Options] */
// Use Gridfinity-compatible base (required for stacking/magnets; disable for simple flat bottom)
enable_gridfinity_base = true;
// Plain bottom thickness (when gridfinity base disabled)
plain_bottom_thickness = 2; // [1:0.5:5]
// Plain bottom chamfer size (decorative edge bevel)
plain_bottom_chamfer = 1; // [0:0.5:3]
// Magnet holes (6mm × 2mm magnets)
magnet_holes = false;
// Screw holes (M3 screws)
screw_holes = false;
// Corner holes only (faster print, use with magnets/screws)
only_corners = false;
// Refined hole style (smooth, not compatible with magnets)
refined_holes = false;
// Crush ribs for magnet grip
crush_ribs = true;
// Chamfered holes for easy insertion
chamfer_holes = true;

/* [Advanced: Rendering] */
// Detail level (lower = smoother curves, slower render)
curve_detail = 2; // [0.5:0.25:4]

/* [Hidden] */
$fa = 4;
$fs = curve_detail;
// Base subdivision (kept hidden). Default 0 uses mixed full/half tiles for x.5 sizes.
div_base_x = 0;
div_base_y = 0;
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

// Full holder footprint radius (hole + rim + taper)
holder_footprint_radius = (cylinder_diameter / 2 + holder_clearance / 2) + holder_rim_thickness + holder_rim_taper;

// Usable area for bottle placement (accounting for walls if enabled)
usable_margin = enable_tray_wall ? tray_wall_thickness : 0;
usable_width = total_width - usable_margin * 2;
usable_depth = total_depth - usable_margin * 2;

// Center-to-center spacing between holes
// Hole spacing includes fit clearance and minimum wall between holes
holder_spacing = (cylinder_diameter + holder_clearance) + min_wall_between;

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
        // Key improvement: when a tray wall exists, it doesn't need to “contain” the holder rim.
        // We only require the *hole* circle to fit fully inside the tray opening.
        // (Rim walls can merge into the tray wall and will be clipped by it.)
        min_edge_dist = hole_radius,
        avail_w = opening_width - 2 * min_edge_dist,
        avail_h = opening_depth - 2 * min_edge_dist
    )
    assert(
        avail_w >= 0 && avail_h >= 0,
        str(
            "No room for holders: cylinder_diameter=", cylinder_diameter,
            "mm (clearance=", holder_clearance, "mm) is too large for opening ",
            opening_width, "×", opening_depth, "mm. Increase gridx/gridy, reduce tray_wall_thickness, disable tray walls, or disable holders."
        )
    )
    let(
        // Grid positions (preferred when counts are equal)
        grid_positions = generate_grid_positions(avail_w, avail_h, holder_spacing),
        
        // Find best hex configuration
        best_config = find_best_hex_config(avail_w, avail_h, holder_spacing),
        hex_positions = generate_hex_pattern(avail_w, avail_h, holder_spacing, 
                                             best_config[0], best_config[1], best_config[2]),
        
        // Only use hex if it fits MORE bottles (prefer grid when equal)
        use_hex = packing_mode != "grid" && len(hex_positions) > len(grid_positions),
        selected = use_hex ? hex_positions : grid_positions,

        // Center within the opening rectangle (then filter against rounded corners)
        centered = center_positions(selected, avail_w, avail_h, min_edge_dist),
        valid = [
            for (p = centered)
                if (circle_fits_in_rounded_rect(p[0], p[1], opening_width, opening_depth, opening_corner_r, hole_radius))
                    p
        ]
    )
    len(valid) > 0 ? valid : [[opening_width/2, opening_depth/2]];

// ===== Option C helpers (readability) =====
// Keep geometry identical, but reduce repeated formulas/loops.

function bottle_positions() = generate_valid_positions();

function holder_h_total() = holder_recess_depth + holder_rim_height;
function holder_outer_r_top() = ((cylinder_diameter / 2) + (holder_clearance / 2)) + holder_rim_thickness;
function holder_outer_r_bottom() = holder_outer_r_top() + holder_rim_taper;
function holder_hole_r() = (cylinder_diameter / 2) + (holder_clearance / 2);
function holder_floor_z() = holder_start_z + holder_recess_depth;

// Iterate centered XY positions; optionally add a base XY offset and a Z offset.
module for_each_position(pos_list = positions, base_xy = [start_offset_x, start_offset_y], z = 0) {
    translate([base_xy[0], base_xy[1], z])
    for (pos = pos_list)
        translate([pos[0], pos[1], 0])
        children();
}



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

// ===== Placement helpers (needs BASE_OUTSIDE_RADIUS) =====

// Inner opening (the space inside the tray wall). Bottle holes must fit inside this.
opening_width = enable_tray_wall ? (total_width - tray_wall_thickness * 2) : total_width;
opening_depth = enable_tray_wall ? (total_depth - tray_wall_thickness * 2) : total_depth;
opening_corner_r = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;

// True hole radius incl. fit clearance (what must not be clipped by walls/corners)
hole_radius = (cylinder_diameter / 2) + (holder_clearance / 2);

// Test whether a circle of radius `rad` centered at (x,y) fits inside a rounded rectangle
// of size (w,d) with corner radius r. Coordinates are in [0..w], [0..d].
function circle_fits_in_rounded_rect(x, y, w, d, r, rad) =
    let(
        // Convert to centered, positive quadrant
        cx = abs(x - w/2),
        cy = abs(y - d/2),
        // Available extents after keeping the circle inside
        dx = w/2 - rad,
        dy = d/2 - rad,
        rr = max(0, r - rad),
        kx = max(0, cx - (dx - rr)),
        ky = max(0, cy - (dy - rr))
    )
    // Must be inside the inset rectangle, and inside the inset corner circle
    (cx <= dx && cy <= dy) &&
    ((cx <= (dx - rr)) || (cy <= (dy - rr)) || (kx*kx + ky*ky <= rr*rr));

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

holder_start_z = enable_gridfinity_base ? 
    (bp_h_bot - holder_recess_depth) : 
    (plain_bottom_thickness - holder_recess_depth);


// Generate validated and centered bottle positions (skip entirely for empty tray/bin)
positions = enable_holders ? bottle_positions() : [];

// Starting position offset (positions are already centered within usable area)
start_offset_x = -(total_width / 2) + usable_margin;
start_offset_y = -(total_depth / 2) + usable_margin;

// Wall dimensions
wall_inner_width = total_width - tray_wall_thickness * 2;
wall_inner_depth = total_depth - tray_wall_thickness * 2;

// ===== Build pipeline (composition) =====
// These wrappers keep the “what gets built” readable, while leaving the Gridfinity core modules untouched.

// 2D ring for walls (outer minus inner), using rounded rectangles for artifact-free corners
module wall_ring_2d(outer_w, outer_d, wall_thickness, corner_r) {
    inner_w = outer_w - wall_thickness * 2;
    inner_d = outer_d - wall_thickness * 2;
    inner_r = max(0, corner_r - wall_thickness);
    assert(inner_w > 0 && inner_d > 0, "tray_wall_thickness is too large for this grid size");
    difference() {
        rounded_rect_2d(outer_w, outer_d, corner_r);
        rounded_rect_2d(inner_w, inner_d, inner_r);
    }
}

// 2D honeycomb mesh panel (solid rect with hex holes) - from reference library
// Adapted from https://www.printables.com/model/575405-honeycomb-library-remix-for-openscad
module honeycomb_mesh_2d(panel_w, panel_h, cell_size=8, wall_rib=1.2) {
    smallDia = cell_size * cos(30);
    projWall = wall_rib * cos(30);
    
    yStep = smallDia + wall_rib;
    xStep = cell_size * 3/2 + projWall * 2;
    
    yStepsCount = ceil((panel_h/2) / yStep) + 1;
    xStepsCount = ceil((panel_w/2) / xStep) + 1;
    
    // Generate honeycomb MESH (solid with hex holes)
    difference() {
        square([panel_w, panel_h], center=true);
        
        for (yOffset = [-yStep * yStepsCount : yStep : yStep * yStepsCount])
        for (xOffset = [-xStep * xStepsCount : xStep : xStep * xStepsCount]) {
            translate([xOffset, yOffset])
            circle(d = cell_size, $fn = 6);
            
            translate([xOffset + cell_size*3/4 + projWall, yOffset + (smallDia + wall_rib)/2])
            circle(d = cell_size, $fn = 6);
        }
    }
}

// Stackable receiver: carve a Gridfinity-style 2-chamfer pocket into the *inside top* of the wall.
// This is built from the same dimensions as BASE_PROFILE (0.8 / 1.8 / 2.15 @ 45°).
module stacking_receiver_cut(outer_w, outer_d, wall_thickness, corner_r, clearance_total=0.3) {
    // Keep some outer wall so we never perforate the outside.
    min_outer_wall = 0.6;
    max_cut = max(0, wall_thickness - min_outer_wall);
    // Clearance is total; apply half per side.
    // IMPORTANT: clearance should never change the *shape* of the Gridfinity profile,
    // only the amount of extra room around it. So we apply clearance as an added
    // offset to all insets equally (bounded by available wall thickness).
    clear_req = max(0, clearance_total / 2);

    // Receiver depth: stacked Gridfinity base inserts about 5mm.
    receiver_depth_total = BASEPLATE_LIP_HEIGHT; // 5

    // If the existing inner opening already fits the incoming Gridfinity base at insertion depth,
    // don't modify the wall at all. This preserves the original wall profile and avoids a pointless
    // "boundary shelf" in cases where there would be no contact anyway.
    foot_inset = BASE_PROFILE_MAX.x - BASEPLATE_LIP[1].x; // 2.95 - 0.7 = 2.25
    required_inner_w = outer_w - 2 * foot_inset + clearance_total;
    required_inner_d = outer_d - 2 * foot_inset + clearance_total;
    inner_w0 = outer_w - wall_thickness * 2;
    inner_d0 = outer_d - wall_thickness * 2;
    t_need = max(0, max((required_inner_w - inner_w0) / 2, (required_inner_d - inner_d0) / 2));
    // We only widen the receiver if we actually need to for fit.
    // If not needed, we still add a small *entrance-only* chamfer (shallow, no deep shelf).
    t_need_eff = t_need;

    // Base (spec) insets with NO clearance (these define the *shape*).
    top_raw = min(max_cut, BASE_PROFILE_MAX.x);     // up to 2.95 revealed as wall thickens
    mid_raw_base = min(max_cut, 0.8);              // 0.8mm chamfer/shelf region
    // CRITICAL: at full insertion depth the opening must fit the Gridfinity foot (~37mm).
    // So when widening is required, we must allow bot_raw to grow beyond 0.7mm/side.
    bot_raw = min(max_cut, t_need_eff);
    // Ensure monotonic opening (top >= mid >= bottom) so we never invert the bevel.
    mid_raw = max(mid_raw_base, bot_raw);

    // Apply clearance uniformly to all insets, but never beyond available material.
    clear = min(clear_req, max(0, max_cut - top_raw));
    t_top = top_raw + clear;
    t_mid = mid_raw + clear;
    t_bot = bot_raw + clear;

    // Segment heights (45°) depend only on the *raw* insets (shape reveal), not clearance.
    // This preserves the Gridfinity chamfer angles as wall thickness reveals more.
    segA_h = min(2.15, max(0, top_raw - mid_raw)); // big chamfer (<=2.15)
    segB_h = (max_cut >= 0.8) ? 1.8 : 0;           // vertical section (only if we can reach 0.8 inset)
    segC_h = min(0.8, max(0, mid_raw - bot_raw));  // small chamfer (<=0.8; may be 0 if bottom needs widening)
    // We avoid a “double cut line” by extending the bottom segment to the full insertion depth,
    // rather than doing a second separate extension.

    // Expanded opening shape at the wall's inner edge (solid 2D).
    // Using solids (not rings) avoids hull() artifacts that can look “stepped”.
    module opening_expanded(t) {
        t2 = max(0, t);
        inner_w0 = outer_w - wall_thickness * 2;
        inner_d0 = outer_d - wall_thickness * 2;
        inner_r0 = max(0, corner_r - wall_thickness);
        rounded_rect_2d(inner_w0 + t2 * 2, inner_d0 + t2 * 2, inner_r0 + t2);
    }

    if (max_cut > 0.001) {
        if (t_need_eff > 0.001) {
            // Receiver needed for fit: spec-like (two 45° chamfers + optional vertical),
            // with the bottom segment reaching the full 5mm insertion depth (no extra “second profile”).
            union() {
                // A: big chamfer (top)
                if (segA_h > 0.001 && t_top > 0.001) {
                    hull() {
                        translate([0, 0, 0]) linear_extrude(0.05) opening_expanded(t_top);
                        translate([0, 0, -segA_h]) linear_extrude(0.05) opening_expanded(t_mid);
                    }
                }
                // B: vertical section
                if (segB_h > 0.001 && t_mid > 0.001) {
                    translate([0, 0, -segA_h - segB_h])
                    linear_extrude(segB_h)
                    opening_expanded(t_mid);
                }
                // C: bottom segment (extends to full depth)
                if (t_mid > 0.001) {
                    hull() {
                        translate([0, 0, -segA_h - segB_h]) linear_extrude(0.05) opening_expanded(t_mid);
                        translate([0, 0, -receiver_depth_total]) linear_extrude(0.05) opening_expanded(t_bot);
                    }
                }
            }
        } else {
            // No receiver widening required: add a shallow entrance chamfer only (supportless, no deep shelf).
            // Match Gridfinity's small chamfer size (0.8mm @ 45°) for consistent top engagement.
            entry = min(0.8, max_cut);
            if (entry > 0.01) {
                hull() {
                    translate([0, 0, 0]) linear_extrude(0.05) opening_expanded(entry);
                    translate([0, 0, -entry]) linear_extrude(0.05) opening_expanded(0);
                }
            }
        }
    }
}

// Supportless alignment ramps to help center a stacking Gridfinity base.
// These are small 45° wedges that protrude slightly inward near the very top of the stacking band.
//
// IMPORTANT: These ramps must attach to the *receiver opening* at the top of the band (which is widened
// by the receiver cut). So we compute the receiver's top opening size here rather than using the raw
// inner wall size.
module stacking_alignment_ramps(outer_w, outer_d, wall_thickness, corner_r, band_h, clearance_total=0.3, ramp_h=3.0) {
    eps = 0.05;
    h = min(ramp_h, band_h);
    // IMPORTANT: do not protrude into the cavity at the exact top seating plane.
    // We keep the very top “anchor” of the ramp inside the wall material (not inside the opening),
    // so the stacked bin can fully seat flush while the ramp still starts exactly at the bevel entrance.
    // Ensure ramps actually *overlap* the wall (not just touch), so they union into one solid.
    attach_overlap = 0.10;
    if (h <= 0) {
        // no ramps
    } else {
    // Raw inner wall opening (no receiver widening)
    inner_w0 = outer_w - wall_thickness * 2;
    inner_d0 = outer_d - wall_thickness * 2;
    inner_r0 = max(0, corner_r - wall_thickness);

    // Alignment ramps are most useful when the fit is *loose* (thin walls): the base fits without widening,
    // but has lateral play. When widening is required (thicker walls), the receiver itself provides alignment,
    // so we skip ramps to avoid unnecessary features.
    foot_inset = BASE_PROFILE_MAX.x - BASEPLATE_LIP[1].x; // 2.25
    required_inner_w = outer_w - 2 * foot_inset + clearance_total;
    required_inner_d = outer_d - 2 * foot_inset + clearance_total;
    t_need = max(0, max((required_inner_w - inner_w0) / 2, (required_inner_d - inner_d0) / 2));
    if (t_need > 0.001) {
        // no ramps (receiver widening will handle alignment)
    } else {
    // Compute the *actual* top opening of the pocket for the loose-fit case.
    // In the loose-fit case, stacking_receiver_cut() only adds an entrance chamfer (no widening),
    // so ramps must attach to that entrance chamfer, not to a hypothetical full receiver opening.
    min_outer_wall = 0.6;
    max_cut = max(0, wall_thickness - min_outer_wall);
    entry = min(0.8, max_cut); // matches stacking_receiver_cut() entrance chamfer
    t_top = entry;

    // Receiver opening at the very top of the band (widened)
    open_w = inner_w0 + t_top * 2;
    open_d = inner_d0 + t_top * 2;
    open_r = inner_r0 + t_top;

    // Compute how loose the fit is at the *top opening* (entry chamfer increases opening).
    play_w = max(0, (open_w - required_inner_w) / 2);
    play_d = max(0, (open_d - required_inner_d) / 2);
    play = max(play_w, play_d);
    min_play_for_ramps = 0.08;
    if (play < min_play_for_ramps) {
        // no ramps (already effectively centered)
    } else {

    // Keep within corners; scale ramp length with grid size
    max_len_x = max(0, open_d - 2 * (open_r + 1));
    max_len_y = max(0, open_w - 2 * (open_r + 1));
    // Use specified % of available side (scales from 1x1 to large grids)
    ramp_scale = stacking_ramp_length_percent / 100;
    len_x = max(12, max_len_x * ramp_scale);
    len_y = max(12, max_len_y * ramp_scale);

    // Ramp depth/height: take up the play so it actually engages, but keep it supportless.
    // TOP face matches Gridfinity: 45° (depth == height).
    // BOTTOM is just a supportless 45° return (no long vertical wall).
    d = min(max(0.8, play), band_h / 2);
    top_h = d;
    bot_h = d;

    // +X / -X ramps (extruded along Y); add end chamfers for clean look
    if (len_x > 0) {
        end_ch = min(1.0, len_x / 3); // chamfer on short ends
        // 3-stage ramp: 0 -> depth -> 0 (all supportless)
        // +X face (attach at x = +open_w/2)
        hull() {
            // Top anchor: entirely in the wall; inset at ends for chamfer
            translate([open_w/2, -len_x/2 + end_ch, band_h])
            cube([eps + attach_overlap, len_x - 2*end_ch, eps], center=false);
            // Downward 45° ramp into the cavity
            translate([open_w/2 - d, -len_x/2 + end_ch, band_h - top_h])
            cube([d + attach_overlap, len_x - 2*end_ch, eps], center=false);
        }
        hull() {
            translate([open_w/2 - d, -len_x/2 + end_ch, band_h - top_h])
            cube([d + attach_overlap, len_x - 2*end_ch, eps], center=false);
            translate([open_w/2 - eps, -len_x/2 + end_ch, band_h - top_h - bot_h])
            cube([eps + attach_overlap, len_x - 2*end_ch, eps], center=false);
        }
        // -X face (attach at x = -open_w/2)
        hull() {
            translate([-open_w/2 - attach_overlap, -len_x/2 + end_ch, band_h])
            cube([eps + attach_overlap, len_x - 2*end_ch, eps], center=false);
            translate([-open_w/2 - attach_overlap, -len_x/2 + end_ch, band_h - top_h])
            cube([d + attach_overlap, len_x - 2*end_ch, eps], center=false);
        }
        hull() {
            translate([-open_w/2 - attach_overlap, -len_x/2 + end_ch, band_h - top_h])
            cube([d + attach_overlap, len_x - 2*end_ch, eps], center=false);
            translate([-open_w/2 - attach_overlap, -len_x/2 + end_ch, band_h - top_h - bot_h])
            cube([eps + attach_overlap, len_x - 2*end_ch, eps], center=false);
        }
    }

    // +Y / -Y ramps (extruded along X); add end chamfers for clean look
    if (len_y > 0) {
        end_ch_y = min(1.0, len_y / 3);
        // 3-stage ramp: 0 -> depth -> 0 (supportless)
        // +Y face (attach at y = +open_d/2)
        hull() {
            translate([-len_y/2 + end_ch_y, open_d/2, band_h])
            cube([len_y - 2*end_ch_y, eps + attach_overlap, eps], center=false);
            translate([-len_y/2 + end_ch_y, open_d/2 - d, band_h - top_h])
            cube([len_y - 2*end_ch_y, d + attach_overlap, eps], center=false);
        }
        hull() {
            translate([-len_y/2 + end_ch_y, open_d/2 - d, band_h - top_h])
            cube([len_y - 2*end_ch_y, d + attach_overlap, eps], center=false);
            translate([-len_y/2 + end_ch_y, open_d/2 - eps, band_h - top_h - bot_h])
            cube([len_y - 2*end_ch_y, eps + attach_overlap, eps], center=false);
        }
        // -Y face (attach at y = -open_d/2)
        hull() {
            translate([-len_y/2 + end_ch_y, -open_d/2 - attach_overlap, band_h])
            cube([len_y - 2*end_ch_y, eps + attach_overlap, eps], center=false);
            translate([-len_y/2 + end_ch_y, -open_d/2 - attach_overlap, band_h - top_h])
            cube([len_y - 2*end_ch_y, d + attach_overlap, eps], center=false);
        }
        hull() {
            translate([-len_y/2 + end_ch_y, -open_d/2 - attach_overlap, band_h - top_h])
            cube([len_y - 2*end_ch_y, d + attach_overlap, eps], center=false);
            translate([-len_y/2 + end_ch_y, -open_d/2 - attach_overlap, band_h - top_h - bot_h])
            cube([len_y - 2*end_ch_y, eps + attach_overlap, eps], center=false);
        }
    }
    }
    }
    }
}

module build_gridfinity_base() {
    if (enable_gridfinity_base) {
        // Gridfinity base - clipped to match wall footprint for fractional grids
        // Force CGAL evaluation so OpenCSG preview doesn't leak intersection solids.
        render() intersection() {
            gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, hole_options, 0, true, only_corners);
            // Clip to wall outer boundary
            translate([0, 0, -1])
            linear_extrude(h_base + 10)
            rounded_rect_2d(total_width, total_depth, BASE_OUTSIDE_RADIUS);
        }
    } else {
        // Simple flat bottom (non-gridfinity) with chamfered edges.
        // Build this directly (instead of subtracting oversized chamfer volumes) so:
        // - the model stays on Z=0 (no “floating” base)
        // - we don't create a visible bottom “flange” under the tray walls
        render()
        union() {
            base_w = total_width;
            base_d = total_depth;
            base_r = BASE_OUTSIDE_RADIUS;
            base_h = plain_bottom_thickness + 0.5; // extend slightly into holders/walls for clean fusion

            // Bottom chamfer is always safe.
            ch_req = plain_bottom_chamfer;
            ch_bottom = min(ch_req, base_h - 0.05, min(base_w, base_d)/2 - 0.05);
            // Top chamfer is cosmetic; only apply when there are NO tray walls (otherwise it undercuts the wall start).
            ch_top_req = enable_tray_wall ? 0 : ch_req;
            ch_top = min(ch_top_req, base_h - ch_bottom - 0.05, min(base_w, base_d)/2 - 0.05);

            // Dimensions for the chamfered “inner” profile (at the chamfer tips).
            inner_w_b = base_w - 2*ch_bottom;
            inner_d_b = base_d - 2*ch_bottom;
            inner_r_b = max(0, base_r - ch_bottom);

            inner_w_t = base_w - 2*ch_top;
            inner_d_t = base_d - 2*ch_top;
            inner_r_t = max(0, base_r - ch_top);

            // Bottom chamfer section (45° bevel): smaller at Z=0 → full size at Z=ch_bottom
            if (ch_bottom > 0.01) {
                hull() {
                    translate([0, 0, 0]) linear_extrude(0.05)
                    rounded_rect_2d(inner_w_b, inner_d_b, inner_r_b);
                    translate([0, 0, ch_bottom]) linear_extrude(0.05)
                    rounded_rect_2d(base_w, base_d, base_r);
                }
            }

            // Middle straight section
            mid_z0 = ch_bottom;
            mid_h = base_h - ch_bottom - ch_top;
            if (mid_h > 0.01) {
                translate([0, 0, mid_z0])
                linear_extrude(mid_h)
                rounded_rect_2d(base_w, base_d, base_r);
            }

            // Top chamfer section (optional): full size at Z=base_h-ch_top → smaller at Z=base_h
            if (ch_top > 0.01) {
                hull() {
                    translate([0, 0, base_h - ch_top]) linear_extrude(0.05)
                    rounded_rect_2d(base_w, base_d, base_r);
                    translate([0, 0, base_h]) linear_extrude(0.05)
                    rounded_rect_2d(inner_w_t, inner_d_t, inner_r_t);
                }
            }
        }
    }
}

module build_holders() {
    if (!enable_holders) {
        // Empty tray/bin mode
    } else {
    // Holder rims with holes - only clip these if wall is enabled
    clip_width = enable_tray_wall ? wall_inner_width : total_width;
    clip_depth = enable_tray_wall ? wall_inner_depth : total_depth;
    clip_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;
    
    // Small overlap to ensure proper boolean union with base (manifold requirement)
    base_overlap = 0.1;
    // Clip only needs to cover the holder Z-range; keeping this small avoids preview artifacts.
    holder_clip_h = holder_start_z + holder_h_total() + 6;

    // Force CGAL for this intersection so preview matches render.
    render() intersection() {
        difference() {
            // Holder rim solids - tapered outer, extend slightly into base
            for_each_position(z = holder_start_z - base_overlap)
                cylinder(holder_h_total() + base_overlap, holder_outer_r_bottom(), holder_outer_r_top());
            
            // Cut straight holes through holders
            for_each_position(z = holder_start_z - base_overlap - 0.1)
                cylinder(holder_h_total() + base_overlap + 0.2, holder_hole_r(), holder_hole_r());
        }
        // Clip holder rims to fit inside wall
        translate([0, 0, -1])
        linear_extrude(holder_clip_h)
        rounded_rect_2d(clip_width, clip_depth, clip_radius);
    }
    }
}

module build_raised_floor() {
    // Raised floor to fill empty space between bottles
    if (enable_raised_floor) {
        // Floor height from holder floor (cap to rim height only when holders exist)
        floor_height = enable_holders ? min(raised_floor_height, holder_rim_height) : raised_floor_height;
        // Actual holder floor Z (where objects sit, after recess)
        holder_floor_z = holder_floor_z();
        
        // Floor dimensions - fit inside wall if enabled
        floor_width = enable_tray_wall ? wall_inner_width : total_width;
        floor_depth = enable_tray_wall ? wall_inner_depth : total_depth;
        floor_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;
        
        if (enable_holders) {
            // Force CGAL evaluation so preview matches render (web customizers).
            render() difference() {
                // Solid floor block - starts at holder floor
                translate([0, 0, holder_floor_z])
                linear_extrude(floor_height)
                rounded_rect_2d(floor_width, floor_depth, floor_radius);
                
                // Cut out bottle holes - slightly larger than holder rim to avoid coincident faces
                floor_clearance = 0.05;  // Small clearance to avoid manifold issues
                for_each_position(base_xy = [start_offset_x, start_offset_y], z = holder_floor_z - 0.1)
                    cylinder(floor_height + 0.2, 
                            holder_outer_r_bottom() + floor_clearance, 
                            holder_outer_r_top() + floor_clearance);
            }
        } else {
            // Empty tray/bin mode: raised floor is a solid slab (no holes)
            render()
            translate([0, 0, holder_floor_z])
            linear_extrude(floor_height)
            rounded_rect_2d(floor_width, floor_depth, floor_radius);
        }
    }
}

// 2D corner protection zones for lattice (prevents honeycomb from cutting corners)
module corner_protection_zones_2d(total_width, total_depth, corner_margin) {
    // Create exclusion zones in all 4 corners
    for (sx = [-1, 1])
    for (sy = [-1, 1]) {
        translate([sx * total_width/2, sy * total_depth/2])
        square([corner_margin * 2, corner_margin * 2], center=true);
    }
}

// 2D global honeycomb hex pattern (tiles across entire area)
module honeycomb_hex_pattern_global_2d(area_w, area_h, cell_size=8, wall_rib=1.2) {
    // Use same tiling math as honeycomb_mesh_2d but generate hex circles only (no background)
    smallDia = cell_size * cos(30);
    projWall = wall_rib * cos(30);
    
    yStep = smallDia + wall_rib;
    xStep = cell_size * 3/2 + projWall * 2;
    
    yStepsCount = ceil((area_h/2) / yStep) + 2;
    xStepsCount = ceil((area_w/2) / xStep) + 2;
    
    // Generate hex circles across entire area
    for (yOffset = [-yStep * yStepsCount : yStep : yStep * yStepsCount])
    for (xOffset = [-xStep * xStepsCount : xStep : xStep * xStepsCount]) {
        translate([xOffset, yOffset])
        circle(d = cell_size, $fn = 6);
        
        translate([xOffset + cell_size*3/4 + projWall, yOffset + (smallDia + wall_rib)/2])
        circle(d = cell_size, $fn = 6);
    }
}

module build_tray_wall() {
    if (enable_tray_wall) {
        // Wall starts at top of base (gridfinity shoulder or plain bottom)
        wall_start_z = enable_gridfinity_base ? h_base : plain_bottom_thickness;
        corner_radius = BASE_OUTSIDE_RADIUS;
        // Stacking is only meaningful for Gridfinity-style walls/base.
        stacking_enabled = enable_stacking && enable_gridfinity_base;
        stacking_band_h = stacking_enabled ? BASEPLATE_LIP_HEIGHT : 0;

        // Height handling
        // Gridfinity Z unit: 7mm == 1u
        z_u = 7;
        base_top_z_ref = enable_gridfinity_base ? z_u : plain_bottom_thickness;
        holder_floor_z_local = holder_floor_z();

        desired_top_z_raw =
            (height_mode == "object") ?
                (holder_floor_z_local + object_height + object_height_clearance) :
            (height_mode == "exclude_base") ?
                (base_top_z_ref + height_excluding_base) :
                total_height;

        // Optionally snap object-fit height to Gridfinity units (keeps bins aligned in Z).
        desired_top_z =
            (height_mode == "object" && snap_object_height_to_u && enable_gridfinity_base) ?
                (ceil(desired_top_z_raw / z_u) * z_u) :
                desired_top_z_raw;

        // Avoid invalid/negative heights if user chooses very small totals.
        desired_top_z_clamped = max(desired_top_z, wall_start_z + stacking_band_h + 0.1);
        desired_wall_total_h = desired_top_z_clamped - wall_start_z;
        // Main wall height excludes stacking band; clamp to stay valid.
        wall_base_height = max(0.1, desired_wall_total_h - stacking_band_h);
        wall_total_height = wall_base_height + stacking_band_h;
        eps = 0.03;

        translate([0, 0, wall_start_z])
        union() {
            if (wall_pattern == "lattice" && wall_total_height > 10) {
                // Lattice mode: SINGLE-PIECE architecture - build full wall, subtract honeycomb from each face
                solid_top = stacking_enabled ? 6 : 4;
                floor_top_z = enable_raised_floor ? min(raised_floor_height, holder_rim_height) : 0;
                // Lattice starts at: base level (0 or raised floor top + 1mm clearance) + user-defined bottom rim
                lattice_base = enable_raised_floor ? floor_top_z + 1 : 0;
                lattice_start = lattice_base + lattice_bottom_rim;
                lattice_end = wall_total_height - solid_top;
                lattice_h = lattice_end - lattice_start;
                
                if (lattice_h >= 5) {
                    // Corner protection margin
                    corner_margin = corner_radius + lattice_corner_margin;
                    flat_w = total_width - 2 * (corner_radius + lattice_corner_margin);
                    flat_d = total_depth - 2 * (corner_radius + lattice_corner_margin);
                    
                    // render() forces CGAL evaluation so preview matches render
                    render() difference() {
                        // Build FULL solid wall ring (single continuous piece)
                        linear_extrude(wall_total_height)
                        wall_ring_2d(total_width, total_depth, tray_wall_thickness, corner_radius);
                        
                        // Subtract honeycomb hex holes from each wall face (4 separate cuts, not union)
                        // +X face
                        translate([total_width/2 - tray_wall_thickness/2, 0, lattice_start + lattice_h/2])
                        rotate([90, 0, 90])
                        linear_extrude(tray_wall_thickness + 1, center=true)
                        intersection() {
                            square([flat_d, lattice_h], center=true);
                            honeycomb_hex_pattern_global_2d(flat_d + 10, lattice_h + 10, lattice_cell_size, lattice_rib_thickness);
                        }
                        
                        // -X face
                        translate([-total_width/2 + tray_wall_thickness/2, 0, lattice_start + lattice_h/2])
                        rotate([90, 0, 90])
                        linear_extrude(tray_wall_thickness + 1, center=true)
                        intersection() {
                            square([flat_d, lattice_h], center=true);
                            honeycomb_hex_pattern_global_2d(flat_d + 10, lattice_h + 10, lattice_cell_size, lattice_rib_thickness);
                        }
                        
                        // +Y face
                        translate([0, total_depth/2 - tray_wall_thickness/2, lattice_start + lattice_h/2])
                        rotate([90, 0, 0])
                        linear_extrude(tray_wall_thickness + 1, center=true)
                        intersection() {
                            square([flat_w, lattice_h], center=true);
                            honeycomb_hex_pattern_global_2d(flat_w + 10, lattice_h + 10, lattice_cell_size, lattice_rib_thickness);
                        }
                        
                        // -Y face
                        translate([0, -total_depth/2 + tray_wall_thickness/2, lattice_start + lattice_h/2])
                        rotate([90, 0, 0])
                        linear_extrude(tray_wall_thickness + 1, center=true)
                        intersection() {
                            square([flat_w, lattice_h], center=true);
                            honeycomb_hex_pattern_global_2d(flat_w + 10, lattice_h + 10, lattice_cell_size, lattice_rib_thickness);
                        }
                        
                        // Receiver pocket
                        if (stacking_enabled && stacking_band_h > 0.01) {
                            translate([0, 0, wall_total_height + eps])
                            stacking_receiver_cut(total_width, total_depth, tray_wall_thickness, corner_radius, stacking_clearance);
                        }
                    }
                } else {
                    // Too little height for a meaningful lattice band; fall back to solid wall
                    render() difference() {
                        linear_extrude(wall_total_height)
                        wall_ring_2d(total_width, total_depth, tray_wall_thickness, corner_radius);

                        // Receiver pocket
                        if (stacking_enabled && stacking_band_h > 0.01) {
                            translate([0, 0, wall_total_height + eps])
                            stacking_receiver_cut(total_width, total_depth, tray_wall_thickness, corner_radius, stacking_clearance);
                        }
                    }
                }
            } else {
                // Solid wall mode
                // Force CGAL evaluation so preview matches render (web customizers).
                render() difference() {
                    linear_extrude(wall_total_height)
                    wall_ring_2d(total_width, total_depth, tray_wall_thickness, corner_radius);

                    // Receiver pocket
                    if (stacking_enabled && stacking_band_h > 0.01) {
                        translate([0, 0, wall_total_height + eps])
                        stacking_receiver_cut(total_width, total_depth, tray_wall_thickness, corner_radius, stacking_clearance);
                    }
                }
            }

            // Optional alignment ramps (supportless) to center a stacked base.
            if (stacking_enabled && stacking_band_h > 0.01) {
                translate([0, 0, wall_total_height - stacking_band_h])
                stacking_alignment_ramps(total_width, total_depth, tray_wall_thickness, corner_radius, stacking_band_h, stacking_clearance);
            }
        }
    }
}

module main() {
    union() {
        build_gridfinity_base();
        build_holders();
        build_raised_floor();
        build_tray_wall();
    }
}


// ===== Modules ===== //

// (Removed unused legacy/reference stacking modules to reduce confusion.)

// (Stacking receiver removed — plain walls only.)

// (Removed unused legacy/reference stacking receiver cutter.)

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
    // Gridfinity pitch is `length` (normally 42mm). The physical gap between feet is fixed
    // at (length - BASE_SIZE) == 0.5mm, even when half-units are used.
    gap = length - BASE_SIZE;

    // If dx/dy are left at 0 (default), use a mixed tiling approach for x.5 sizes:
    // keep full-size feet for the integer portion, and add only the needed half/quarter feet.
    // This matches real "full + half" baseplates and avoids the "chocolate bar" of all-half feet.
    use_mixed_halves = (dx == 0 && dy == 0) &&
        (abs(gx * 2 - round(gx * 2)) < 0.001) &&
        (abs(gy * 2 - round(gy * 2)) < 0.001);

    // Overall outer size (matches total_width/total_depth)
    grid_size_mm = [gx * length - gap, gy * length - gap];

    if (final_cut) {
        // Use seam-free rounded rectangle to avoid offset() artifacts and ensure smooth corners
        // even for fractional grid sizes (e.g. 0.5u).
        translate([0, 0, h_base - TOLLERANCE])
        linear_extrude(h_bot)
        rounded_rect_2d(grid_size_mm.x, grid_size_mm.y, BASE_OUTSIDE_RADIUS);
    }

    if (use_mixed_halves) {
        // Segment sizes along each axis: N full feet, plus optional half-foot remainder.
        size_full = BASE_SIZE;
        size_half = length/2 - gap;

        gx_full = floor(gx + 0.001);
        gy_full = floor(gy + 0.001);
        gx_half = (gx - gx_full) > 0.25;
        gy_half = (gy - gy_full) > 0.25;

        x_sizes = concat([for (i = [1:gx_full]) size_full], gx_half ? [size_half] : []);
        y_sizes = concat([for (i = [1:gy_full]) size_full], gy_half ? [size_half] : []);

        // Center positions for each segment, preserving a fixed `gap` between segments.
        x_centers = [
            for (i = 0, pos = -grid_size_mm.x/2; i < len(x_sizes); pos = pos + x_sizes[i] + gap, i = i + 1)
                pos + x_sizes[i]/2
        ];
        y_centers = [
            for (i = 0, pos = -grid_size_mm.y/2; i < len(y_sizes); pos = pos + y_sizes[i] + gap, i = i + 1)
                pos + y_sizes[i]/2
        ];

        if (only_corners) {
            difference() {
                for (xi = [0 : len(x_sizes) - 1])
                for (yi = [0 : len(y_sizes) - 1])
                    translate([x_centers[xi], y_centers[yi], 0])
                    block_base(bundle_hole_options(), 0, [x_sizes[xi], y_sizes[yi]]);

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
        } else {
            for (xi = [0 : len(x_sizes) - 1])
            for (yi = [0 : len(y_sizes) - 1])
                translate([x_centers[xi], y_centers[yi], 0])
                block_base(hole_options, off, [x_sizes[xi], y_sizes[yi]]);
        }
    } else {
        // Fallback: uniform subdivision logic (supports arbitrary fractions if dx/dy are provided).
        dbnxt = [for (i = [1:5]) if (abs(gx*i)%1 < 0.001 || abs(gx*i)%1 > 0.999) i];
        dbnyt = [for (i = [1:5]) if (abs(gy*i)%1 < 0.001 || abs(gy*i)%1 > 0.999) i];
        dbnx = 1/(dx != 0 ? round(dx) : (len(dbnxt) > 0 ? dbnxt[0] : 1));
        dbny = 1/(dy != 0 ? round(dy) : (len(dbnyt) > 0 ? dbnyt[0] : 1));

        // Final size in number of bases
        grid_size = [gx/dbnx, gy/dbny];

        base_center_distance_mm = [dbnx, dbny] * length;
        gap_mm = [gap, gap];
        individual_base_size_mm = base_center_distance_mm - gap_mm;

        if (only_corners) {
            difference() {
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
        } else {
            pattern_linear(grid_size.x, grid_size.y, base_center_distance_mm.x, base_center_distance_mm.y)
            block_base(hole_options, off, individual_base_size_mm);
        }
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

            // Add small overlap to avoid coincident faces
            translate([0, 0, -0.01])
            linear_extrude(BASE_PROFILE_MAX.y + 0.02)
            rounded_rect_2d(
                base_bottom_size.x + TOLLERANCE,
                base_bottom_size.y + TOLLERANCE,
                translation_x
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

// Simple 2D rounded rectangle without offset() seam artifacts.
// width/depth are the final outer dimensions.
module rounded_rect_2d(width, depth, radius) {
    assert(is_num(width) && is_num(depth) && width > 0 && depth > 0);
    assert(is_num(radius) && radius >= 0);
    r = min(radius, min(width, depth) / 2);
    if (r <= 0) {
        // Avoid degenerate hull(circle(r=0)) which can produce empty geometry and “brick” artifacts.
        square([width, depth], center = true);
    } else {
        // Force enough fragments so the hull() doesn't “shrink” and create big flat facets/creases.
        // (This is cheap: only 4 circles.)
        // Also rotate the circle so the polygon “seam vertex” doesn't line up on the same axis
        // (this can show up as a vertical ridge on the corner in slicers).
        rect_fn = max(256, ceil((2 * PI * r) / $fs));
        seam_rot = 180 / rect_fn;
        hull() {
            for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx * (width/2 - r), sy * (depth/2 - r)])
                rotate(seam_rot)
                circle(r = r, $fn = rect_fn);
        }
    }
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

// ===== Entry point =====
// MakerWorld expects the model to be produced at top-level; we keep a single entrypoint for readability.
main();

// Optional debug: render a single base hole in isolation if test_options is defined
if(!is_undef(test_options)){
    block_base_hole(test_options);
}


