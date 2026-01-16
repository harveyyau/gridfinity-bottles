# Lattice Wall Pattern - TODO

## Current Status
- Parameter exists: `wall_pattern = "solid" | "lattice"`
- Honeycomb hole generation implemented but **tiling is incorrect**
- Result: vertical bars instead of proper honeycomb mesh

## Problem
The hex cylinders from the reference library's tiling formula create overlapping vertical gaps when applied to the wall ring.

## Fix Needed
Decompose the wall ring into 4 flat rectangular panels (N/S/E/W), apply the reference `difference(rect, hex_pattern)` to each panel separately, then union with solid corner sections.

## Reference
https://www.printables.com/model/575405-honeycomb-library-remix-for-openscad
See `honeycomb.scad` for working tiling logic.
