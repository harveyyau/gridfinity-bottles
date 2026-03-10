/* 
 * Shared parameters for all Gridfinity tray variants.
 * (Cylinders, rectangular pockets, divider bins, etc.)
 */

/* [Grid Size] */
// Gridfinity units wide (1 unit = 42mm)
gridx = 2; // [0.5:0.5:8]
// Gridfinity units deep (1 unit = 42mm)
gridy = 1; // [0.5:0.5:8]

/* [Interior Contents] */
// Generate interior cutouts/holders (disable for an empty tray/bin)
enable_holders = true;

/* [Height (Z)] */
// How to specify tray height (Z):
// - object: tray fits your object height (optionally snapped to 7mm Gridfinity units)
// - exclude_base: height above base top (7mm = 1u)
// - total: total external height including base (7mm = 1u)
height_mode = "exclude_base"; // [object:Fit item height, exclude_base:Height above base, total:Total external height]
// Height above base top when height_mode="exclude_base" (mm; 7mm = 1u)
height_excluding_base = 28; // [7:7:350]
// Total external height including base when height_mode="total" (mm; 7mm = 1u)
total_height = 35; // [7:7:350]

/* [Tray Walls - Recommended!] */
// Add walls around the tray (great for drawer organization!)
enable_tray_wall = true;
// Wall thickness (2mm is strong and prints well)
tray_wall_thickness = 2.0; // [1.5:0.5:4]
// Outer wall style
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
// Floor height above interior floor (cap depends on interior type)
raised_floor_height = 16; // [0:1:60]
// Make tray stackable (requires tray walls + Gridfinity base)
enable_stacking = true;
// Stacking fit tolerance - increase if too tight
stacking_clearance = 0.3; // [0.1:0.05:1]
// Alignment ramp length (percentage of side)
stacking_ramp_length_percent = 50; // [20:10:80]

/* [Advanced: Spacing] */
// Minimum wall thickness between interior holders (mm)
min_wall_between = 0.2; // [0:0.1:8]

/* [Advanced: Base Options] */
// Use Gridfinity-compatible base (required for stacking/magnets; disable for simple flat bottom)
enable_gridfinity_base = true;
// Plain bottom thickness (when gridfinity base disabled)
plain_bottom_thickness = 2; // [1:0.5:8]
// Plain bottom chamfer size (decorative edge bevel)
plain_bottom_chamfer = 1; // [0:0.5:6]
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

