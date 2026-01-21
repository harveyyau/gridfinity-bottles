# Lattice Wall Pattern - Next Session Plan

## Current Status
- Honeycomb pattern **works visually** on all 4 sides ✓
- Cell size + rib thickness adjustable ✓
- Corners and rims solid ✓
- **Issue:** Non-manifold warning persists (10+ separate pieces being unioned)

## Root Cause
Building lattice as **10 separate pieces** (4 honeycomb panels + 4 corners + top rim + bottom rim). Even with overlaps and render(), CGAL can't perfectly fuse all the coplanar junctions.

## Solution for Next Session: Single-Piece Lattice Zone

**New architecture:**
1. Build **ONE continuous lattice band** for the entire wall perimeter (not 4 separate panels)
2. Approach: Start with full solid wall ring, subtract honeycomb hex pattern **globally** in the lattice Z-band, but **protect corners** with exclusion zones
3. Add solid top/bottom rims as before (these are safe, full-perimeter extrusions)

**Implementation:**
```
difference() {
    union() {
        // Full wall ring
        linear_extrude(wall_total_height) wall_ring_2d(...);
    }
    // Subtract honeycomb in lattice band ONLY, protecting corners
    translate([0, 0, lattice_start])
    linear_extrude(lattice_h)
    intersection() {
        // Only cut wall ring area
        wall_ring_2d(...);
        // Subtract corner protection zones
        difference() {
            square([large_enough], center=true);
            for (corners) circle/square exclusions;
        }
        // Honeycomb hex pattern
        honeycomb_hex_circles(...);
    }
}
```

**Test case:** 1×1 grid, tall walls, no stacking/floor (simplest)

## Working Code Location
- Last good commit: `f760d9a`
- Honeycomb tiling math: `honeycomb_mesh_2d()` line ~404
- Current lattice code: `build_tray_wall()` line ~731
