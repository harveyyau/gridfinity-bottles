/*
 * Rectangular pocket specific parameters.
 */

/* [Item & Pockets (Rectangular)] */
// Object width (X) to fit (mm)
object_width = 20; // [3:0.5:200]
// Object depth (Y) to fit (mm)
object_depth = 10; // [3:0.5:200]
// Object height (Z) to fit (mm) — measured end-to-end (used when height_mode="object")
object_height = 30; // [5:1:300]
// Extra clearance for easy fit (mm)
pocket_clearance_xy = 0.5; // [0:0.05:3]
// Pocket wall height above the pocket floor (mm)
pocket_wall_height = 15; // [3:1:80]
// Inside pocket corners (rounded is usually nicer; sharp helps square boxes)
pocket_inner_corner_style = "rounded"; // [rounded:Rounded, sharp:Sharp]
// Inside corner radius (mm) when corners are rounded
pocket_corner_radius = 2.0; // [0:0.5:12]

/* [Advanced: Pocket Details] */
// Wall thickness around each pocket (mm)
pocket_wall_thickness = 2.0; // [1:0.25:6]
// How deep pockets sink into the base (mm)
pocket_recess_depth = 0.9; // [0.0:0.1:4]

/* [Height (Z) - Object Fit] */
// Extra headroom above the object height when height_mode="object"
object_height_clearance = 1; // [0:0.5:10]
// Snap object-fit height up to next 7mm unit (recommended for Gridfinity)
snap_object_height_to_u = true;

