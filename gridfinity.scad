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
// Diameter of your cylinder (measured)
cylinder_diameter = 32; // [10:0.1:100]
// How tall to make the holder rim (keeps cylinders upright)
holder_rim_height = 15; // [5:0.1:50]

/* [Outer Wall] */
// Add walls around the tray (for lifting out of drawer)
enable_tray_wall = false;
// Height of your cylinders (wall will be this tall)
object_height = 50; // [5:0.5:150]
// Wall thickness
tray_wall_thickness = 2.0; // [1:0.5:4]
// Add Gridfinity stacking receiver on top of the wall (adds ~5mm extra height so object_height stays usable when stacked)
enable_stacking = false;
// Total XY clearance for stacking fit (0.2–0.6 typical; total, not per-side)
stacking_clearance = 0.3; // [0:0.1:2]

/* [Raised Floor] */
// Fill gaps between holders with a raised surface
enable_raised_floor = false;
// Floor height (set equal to holder_rim_height for flush surface)
raised_floor_height = 15; // [1:0.1:30]

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
// Extra clearance added to the hole diameter for fit tolerance (total, not per-side)
holder_clearance = 0.5; // [0:0.25:2]
// Minimum gap between holders
min_wall_between = 0; // [0:0.5:5]

/* [Advanced: Rendering] */
// Curve detail in mm (smaller = smoother, slower)
curve_detail = 2; // [0.25:0.25:5]

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
$fs = curve_detail;
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
        avail_h = opening_depth - 2 * min_edge_dist,
        
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

holder_start_z = bp_h_bot - holder_recess_depth;


// Generate validated and centered bottle positions
positions = bottle_positions();

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
    top_raw = min(max_cut, BASE_PROFILE_MAX.x);     // 2.95 revealed as wall thickens
    mid_raw = min(max_cut, 0.8);                   // small chamfer shelf
    bot_raw = min(max_cut, min(BASEPLATE_LIP[1].x, t_need_eff)); // only widen as much as needed at full depth

    // Apply clearance uniformly to all insets, but never beyond available material.
    clear = min(clear_req, max(0, max_cut - top_raw));
    t_top = top_raw + clear;
    t_mid = mid_raw + clear;
    t_bot = bot_raw + clear;

    // Segment heights (45°) depend only on the *raw* insets (shape reveal), not clearance.
    // This preserves the Gridfinity chamfer angles as wall thickness reveals more.
    segA_h = min(2.15, max(0, top_raw - mid_raw)); // big chamfer (<=2.15)
    segB_h = (max_cut >= 0.8) ? 1.8 : 0;           // vertical section (only if we can reach 0.8 inset)
    segC_h = min(0.8, max(0, mid_raw - bot_raw));  // small chamfer (<=0.8)
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
            entry = min(0.4, max_cut); // ~0.4mm 45° lead-in
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
module stacking_alignment_ramps(outer_w, outer_d, wall_thickness, corner_r, band_h, clearance_total=0.3, ramp_h=2.0, ramp_depth=0.6, ramp_len=12) {
    eps = 0.05;
    h = min(ramp_h, band_h);
    // Ensure ramps actually *overlap* the wall (not just touch), so they union into one solid.
    attach_overlap = 0.10;
    if (h <= 0) {
        // no ramps
    } else {
    // Compute receiver top opening (matches stacking_receiver_cut() logic)
    min_outer_wall = 0.6;
    max_cut = max(0, wall_thickness - min_outer_wall);
    top_raw = min(max_cut, BASE_PROFILE_MAX.x);
    clear_req = max(0, clearance_total / 2);
    clear = min(clear_req, max(0, max_cut - top_raw));
    t_top = top_raw + clear;

    // Raw inner wall opening (no receiver widening)
    inner_w0 = outer_w - wall_thickness * 2;
    inner_d0 = outer_d - wall_thickness * 2;
    inner_r0 = max(0, corner_r - wall_thickness);

    // Only add ramps if widening is actually required for fit.
    foot_inset = BASE_PROFILE_MAX.x - BASEPLATE_LIP[1].x; // 2.25
    required_inner_w = outer_w - 2 * foot_inset + clearance_total;
    required_inner_d = outer_d - 2 * foot_inset + clearance_total;
    t_need = max(0, max((required_inner_w - inner_w0) / 2, (required_inner_d - inner_d0) / 2));
    if (t_need <= 0.001) {
        // no ramps (nothing to align against)
    } else {

    // Receiver opening at the very top of the band (widened)
    open_w = inner_w0 + t_top * 2;
    open_d = inner_d0 + t_top * 2;
    open_r = inner_r0 + t_top;

    // Keep within corners
    max_len_x = max(0, open_d - 2 * (open_r + 1));
    max_len_y = max(0, open_w - 2 * (open_r + 1));
    len_x = min(ramp_len, max_len_x);
    len_y = min(ramp_len, max_len_y);
    d = min(ramp_depth, min(open_w, open_d)/4);

    // +X / -X ramps (extruded along Y)
    if (len_x > 0) {
        // 3-stage ramp: 0 -> depth -> 0 (adds a top chamfer as well)
        top_ch = min(0.6, h/2);
        // +X face (attach at x = +open_w/2)
        hull() {
            translate([open_w/2 - eps, -len_x/2, band_h])
            cube([eps + attach_overlap, len_x, eps], center=false);
            translate([open_w/2 - d, -len_x/2, band_h - top_ch])
            cube([d + attach_overlap, len_x, eps], center=false);
        }
        hull() {
            translate([open_w/2 - d, -len_x/2, band_h - top_ch])
            cube([d + attach_overlap, len_x, eps], center=false);
            translate([open_w/2 - eps, -len_x/2, band_h - h])
            cube([eps + attach_overlap, len_x, eps], center=false);
        }
        // -X face (attach at x = -open_w/2)
        hull() {
            translate([-open_w/2 - attach_overlap, -len_x/2, band_h])
            cube([eps + attach_overlap, len_x, eps], center=false);
            translate([-open_w/2 - attach_overlap, -len_x/2, band_h - top_ch])
            cube([d + attach_overlap, len_x, eps], center=false);
        }
        hull() {
            translate([-open_w/2 - attach_overlap, -len_x/2, band_h - top_ch])
            cube([d + attach_overlap, len_x, eps], center=false);
            translate([-open_w/2 - attach_overlap, -len_x/2, band_h - h])
            cube([eps + attach_overlap, len_x, eps], center=false);
        }
    }

    // +Y / -Y ramps (extruded along X)
    if (len_y > 0) {
        top_ch = min(0.6, h/2);
        // +Y face (attach at y = +open_d/2)
        hull() {
            translate([-len_y/2, open_d/2 - eps, band_h])
            cube([len_y, eps + attach_overlap, eps], center=false);
            translate([-len_y/2, open_d/2 - d, band_h - top_ch])
            cube([len_y, d + attach_overlap, eps], center=false);
        }
        hull() {
            translate([-len_y/2, open_d/2 - d, band_h - top_ch])
            cube([len_y, d + attach_overlap, eps], center=false);
            translate([-len_y/2, open_d/2 - eps, band_h - h])
            cube([len_y, eps + attach_overlap, eps], center=false);
        }
        // -Y face (attach at y = -open_d/2)
        hull() {
            translate([-len_y/2, -open_d/2 - attach_overlap, band_h])
            cube([len_y, eps + attach_overlap, eps], center=false);
            translate([-len_y/2, -open_d/2 - attach_overlap, band_h - top_ch])
            cube([len_y, d + attach_overlap, eps], center=false);
        }
        hull() {
            translate([-len_y/2, -open_d/2 - attach_overlap, band_h - top_ch])
            cube([len_y, d + attach_overlap, eps], center=false);
            translate([-len_y/2, -open_d/2 - attach_overlap, band_h - h])
            cube([len_y, eps + attach_overlap, eps], center=false);
        }
    }
    }
    }
}

module build_gridfinity_base() {
    // Gridfinity base - clipped to match wall footprint for fractional grids
intersection() {
        gridfinityBase(gridx, gridy, l_grid, div_base_x, div_base_y, hole_options);
        // Clip to wall outer boundary
        translate([0, 0, -1])
        linear_extrude(h_base + 10)
        rounded_rect_2d(total_width, total_depth, BASE_OUTSIDE_RADIUS);
    }
}

module build_holders() {
    // Holder rims with holes - only clip these if wall is enabled
    clip_width = enable_tray_wall ? wall_inner_width : total_width;
    clip_depth = enable_tray_wall ? wall_inner_depth : total_depth;
    clip_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;

    intersection() {
        difference() {
            // Holder rim solids - tapered outer
            for_each_position(z = holder_start_z)
                cylinder(holder_h_total(), holder_outer_r_bottom(), holder_outer_r_top());
            
            // Cut straight holes through holders
            for_each_position(z = holder_start_z - 0.1)
                cylinder(holder_h_total() + 0.2, holder_hole_r(), holder_hole_r());
        }
        // Clip holder rims to fit inside wall
        translate([0, 0, -1])
        linear_extrude(300)
        rounded_rect_2d(clip_width, clip_depth, clip_radius);
    }
}

module build_raised_floor() {
    // Raised floor to fill empty space between bottles
    if (enable_raised_floor) {
        // Floor height from holder floor (capped to rim height)
        floor_height = min(raised_floor_height, holder_rim_height);
        // Actual holder floor Z (where objects sit, after recess)
        holder_floor_z = holder_floor_z();
        
        // Floor dimensions - fit inside wall if enabled
        floor_width = enable_tray_wall ? wall_inner_width : total_width;
        floor_depth = enable_tray_wall ? wall_inner_depth : total_depth;
        floor_radius = enable_tray_wall ? max(0, BASE_OUTSIDE_RADIUS - tray_wall_thickness) : BASE_OUTSIDE_RADIUS;
        
        difference() {
            // Solid floor block - starts at holder floor
            translate([0, 0, holder_floor_z])
            linear_extrude(floor_height)
            rounded_rect_2d(floor_width, floor_depth, floor_radius);
            
            // Cut out bottle holes - tapered to match holder rim exactly
            for_each_position(base_xy = [start_offset_x, start_offset_y], z = holder_floor_z - 0.1)
                cylinder(floor_height + 0.2, holder_outer_r_bottom(), holder_outer_r_top());
        }
    }
}

module build_tray_wall() {
    if (enable_tray_wall) {
        // Wall starts at h_base (gridfinity top) to preserve base interface
        wall_start_z = h_base;
        // Base wall height to reach object height from holder floor
        // (holder_start_z is the top of the recess; holder floor is holder_start_z + holder_recess_depth)
        holder_floor_z_local = holder_start_z + holder_recess_depth;
        wall_base_height = (holder_floor_z_local - h_base) + object_height;
        corner_radius = BASE_OUTSIDE_RADIUS;
        // Always raise the wall by the Gridfinity stack insertion depth so a stacked bin doesn't reduce usable height.
        // (Even if walls are too thin for a full-depth receiver, extra height doesn't create shelves/overhangs.)
        stacking_band_h = (enable_stacking ? BASEPLATE_LIP_HEIGHT : 0);
        
        // Build as a *single* wall solid to avoid coplanar “touching faces” between wall + stacking band
        // (those show up as non-manifold edges / slicer artifacts).
        wall_total_height = wall_base_height + stacking_band_h;
        eps = 0.03;

        translate([0, 0, wall_start_z])
        union() {
            difference() {
                linear_extrude(wall_total_height)
                wall_ring_2d(total_width, total_depth, tray_wall_thickness, corner_radius);

                // Receiver pocket: cut down from the *top* of the wall. The cutter itself only
                // extends down 5mm (BASEPLATE_LIP_HEIGHT), so it only affects the added stacking band.
                if (enable_stacking && stacking_band_h > 0.01) {
                    translate([0, 0, wall_total_height + eps])
                    stacking_receiver_cut(total_width, total_depth, tray_wall_thickness, corner_radius, stacking_clearance);
                }
            }

            // Optional alignment ramps (supportless) to center a stacked base.
            if (enable_stacking && stacking_band_h > 0.01) {
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

// Simple 2D rounded rectangle without offset() seam artifacts.
// width/depth are the final outer dimensions.
module rounded_rect_2d(width, depth, radius) {
    assert(is_num(width) && is_num(depth) && width > 0 && depth > 0);
    assert(is_num(radius) && radius >= 0);
    r = min(radius, min(width, depth) / 2);
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


