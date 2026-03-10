/*
 * Cylinder-holder specific parameters.
 */

/* [Item & Holders (Cylinders)] */
// Diameter of your cylinders (measured with calipers, add clearance below)
cylinder_diameter = 14.5; // [5:0.1:120]
// Height of your item (mm) — measured end-to-end (used when height_mode="object")
object_height = 51; // [5:1:300]
// Extra clearance for easy fit (0.5mm recommended, increase if too tight)
holder_clearance = 0.5; // [0:0.05:3]
// Height of holder rim that keeps cylinders upright
holder_rim_height = 15; // [5:1:80]

/* [Height (Z) - Object Fit] */
// Extra headroom above the object height when height_mode="object"
object_height_clearance = 1; // [0:0.5:10]
// Snap object-fit height up to next 7mm unit (recommended for Gridfinity)
snap_object_height_to_u = true;

/* [Advanced: Holder Details] */
// Wall thickness around each holder (1.5-3mm recommended)
holder_rim_thickness = 2.0; // [1:0.25:6]
// Extra thickness at base for strength
holder_rim_taper = 1; // [0:0.5:6]
// How deep holders sink into the base (mm)
holder_recess_depth = 0.9; // [0.0:0.1:4]

/* [Advanced: Packing] */
// Cylinder arrangement (auto optimizes spacing)
packing_mode = "auto"; // [auto:Auto pack, grid:Grid]

