# Lattice Wall Pattern - Status

## Goal
Create honeycomb mesh walls (hexagonal ribs) to save filament on large bins while maintaining strength.

## Current Issue
Honeycomb panels are being built correctly (`honeycomb_mesh_2d` generates proper hex mesh), but the union/positioning with solid corners/rims is causing panels to be hidden or creating wrong visual result.

## Approaches Tried
1. ❌ Subtract hex cylinders from full wall → creates "jail bars" (vertical strips)
2. ❌ Build 4 panels then union with corners → panels get covered/hidden
3. ✓ (briefly worked) Direct subtraction showed proper mesh, but had Volumes issues

## Next Steps
1. Simplify: test with 1×1 grid, tall walls, no stacking/floor
2. Debug panel positioning in isolation (render each panel alone)
3. Ensure panels overlap/fuse with corner pieces (not just touch)
4. OR: Accept "jail bars" look and tune spacing to make it acceptable

## Working Features
- `lightweight_base` ✓
- Parameter framework exists ✓
- Honeycomb tiling math correct ✓
