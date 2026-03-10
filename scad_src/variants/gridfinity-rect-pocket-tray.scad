/*
 * Gridfinity Rectangular Pocket Tray
 *
 * Creates Gridfinity-compatible trays with a grid of rectangular pockets
 * for organizing rectangular objects (adapters, tools, small boxes, etc.).
 *
 * 🎯 QUICK START:
 * 1. Measure your object width/depth with calipers
 * 2. Set "object_width" and "object_depth" (add clearance with "pocket_clearance_xy")
 * 3. Measure your item height and set "object_height"
 * 4. Choose "gridx" / "gridy" and "height_mode"
 * 5. Want an empty bin? Set "enable_holders" = false
 */

include <../params/rect_pocket_params.scad>
include <../params/core_params.scad>

/* [Hidden] */
// Map pocket parameters into the shared "holder_*" interface used by the core.
holder_rim_height = pocket_wall_height;
holder_recess_depth = pocket_recess_depth;

include <../core/gridfinity_tray_core.scad>
include <../interiors/rect_pockets.scad>

// ===== Entry point =====
main();

