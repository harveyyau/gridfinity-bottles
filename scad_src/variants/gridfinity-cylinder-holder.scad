/*
 * Gridfinity Cylinder Holder with Honeycomb Lattice Walls
 * 
 * Creates customizable Gridfinity-compatible trays for batteries, paint pots,
 * spice jars, or any cylindrical objects. Features honeycomb lattice walls
 * that save filament and look great.
 *
 * 🎯 QUICK START:
 * 1. Measure your cylinder diameter with calipers
 * 2. Set "cylinder_diameter" (add ~0.5mm clearance)
 * 3. Measure your item height and set "object_height"
 * 4. Choose how tray height is specified in "height_mode"
 * 5. Adjust "gridx" and "gridy" for tray size
 * 6. Want an empty bin? Set "enable_holders" = false
 *
 * 📏 COMMON SIZES:
 * - AA batteries: 14.5mm diameter × 51mm (default)
 * - AAA batteries: 10.5mm diameter × 45mm
 * - Paint pots: 32mm diameter × 40mm
 * - Spice jars: 45mm diameter × 80mm
 */

include <../params/cylinder_params.scad>
include <../params/core_params.scad>

include <../core/gridfinity_tray_core.scad>
include <../interiors/cylinders.scad>

// ===== Entry point =====
main();

