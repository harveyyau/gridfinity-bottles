# Gridfinity Organizers with Honeycomb Lattice Walls

**Customizable Gridfinity-compatible trays for organizing cylindrical and rectangular objects.**

## ✨ Features

- 🏗️ **Gridfinity Compatible** - Works with standard gridfinity baseplates (or use flat bottom!)
- 🐝 **Beautiful Honeycomb Lattice Walls** - Save 40%+ filament while maintaining strength
- 📏 **Fully Customizable** - Adjust every dimension to fit your needs
- 🎨 **Multiple Patterns** - Choose solid walls or elegant lattice design
- 📦 **Stackable Option** - Build vertical storage towers
- 🔧 **Smart Packing (Cylinders)** - Auto-arranges cylinders for optimal fit
- ⚡ **Plain Bottom Option** - Disable gridfinity base for simple standalone organizer

## 🎯 Quick Start

### Cylinder holders (batteries, jars, paint pots)

- Open `gridfinity-cylinder-holder.scad`
- Set `cylinder_diameter` and `object_height`
- Choose `gridx` / `gridy` and `height_mode`

### Rectangular pockets (adapters, tools, small boxes)

- Open `gridfinity-rect-pocket-tray.scad`
- Set `object_width`, `object_depth`, and `object_height`
- Choose `gridx` / `gridy` and `height_mode`

## 🧩 MakerWorld Customizer (Parametric Model Maker)

- Upload a `.scad` file to your MakerWorld model page to enable the **Customize** button:
  - `gridfinity-cylinder-holder.scad` (cylindrical holders)
  - `gridfinity-rect-pocket-tray.scad` (rectangular pockets)
- MakerWorld runs an OpenSCAD-compatible engine (based on the official 2021 release), so keep scripts conservative and test tricky changes.

### (Optional) Export STLs from included presets

- **Cylinder presets**:

```bash
python3 generate_stls.py
```

- **Rect-pocket presets**:

```bash
python3 generate_stls.py --scad gridfinity-rect-pocket-tray.scad --params gridfinity-rect-pocket-tray.json
```

### Common Presets (Built-in, cylinder model):
- **AA Batteries (2x1) - Lattice, Stackable (Default)**
- **AA Batteries (2x1) - Fits Object Height**
- **AA Batteries (2x1) - Flat Bottom**
- **AAA Batteries (2x1) - Lattice, Stackable**
- **18650 Li-ion Cells (2x1) - Lattice**
- **CR123A Cells (2x1) - Lattice**
- **Lip Balm Tubes (2x1) - Lattice**
- **Essential Oil Bottles 15mL (2x2) - Lattice**
- **Microcentrifuge Tubes 1.5mL (2x1) - Solid Walls**
- **Lab Tubes 15mL Conical (2x1) - Lattice**
- **Lab Tubes 50mL Conical (3x2) - Lattice**
- **Empty Tray/Bin (2x1) - No Holders**
- **Paint Pots (2x2) - Lattice**
- **Spice Jars (3x3) - Lattice**

## 🐝 Why Lattice Walls?

Lattice walls offer several advantages:
- **Save Filament**: 40-50% less material than solid walls
- **Faster Prints**: Less material = faster completion
- **Better Looking**: Gorgeous honeycomb pattern
- **Still Strong**: Maintains excellent structural integrity
- **Ventilation**: Great for items that need airflow

## 📐 Key Parameters

### Essential Settings:
- **cylinder_diameter**: Diameter of your items (cylinder model)
- **object_width / object_depth**: Footprint of your item (rect pocket model)
- **object_height**: Height of your item (measured end-to-end)
- **pocket_inner_corner_style**: Rect pockets — `rounded` (default) or `sharp`
- **pocket_corner_radius**: Rect pockets — inside corner radius (used when rounded)
- **height_mode**: How tray Z height is specified (object / exclude base / total)
- **gridx / gridy**: Tray size in gridfinity units (1 unit = 42mm)
- **enable_tray_wall**: Add walls around the tray (recommended!)
- **wall_pattern**: Choose `lattice` or `solid`
- **enable_holders**: Generate holders/pockets (disable for an empty tray/bin)

### Height modes (Z):
- **object**: Tray height is derived from `object_height` (+ `object_height_clearance`), optionally snapped to 7mm (1u)
- **exclude_base**: Set `height_excluding_base` (mm; 7mm = 1u) — height above the base top
- **total**: Set `total_height` (mm; 7mm = 1u) — total external height including base

### Base Options:
- **enable_gridfinity_base**: Use gridfinity base (true) or simple flat bottom (false)
  - Gridfinity: Compatible with baseplate ecosystem, magnets/screws
  - Flat bottom: Simpler, faster to print, standalone use
- **plain_bottom_thickness**: Thickness of flat bottom (1-5mm, default 2mm)
- **plain_bottom_chamfer**: Edge bevel for polished look (0-3mm, default 1mm)

### Lattice Wall Tuning:
- **lattice_cell_size**: 5-12mm (smaller = more detail)
- **lattice_rib_thickness**: 1.2-2mm (thicker = stronger)
- **lattice_corner_margin**: 3-10mm (solid corners for strength)
- **lattice_bottom_rim**: 0-10mm (solid base height)

### Optional Features:
- **enable_raised_floor**: Fill gaps between holders
- **enable_stacking**: Make trays stackable
- **holder_clearance**: Adjust fit (0.5mm default)

## 🖨️ Printing Recommendations

### Settings:
- **Layer Height**: 0.2mm (0.15mm for finer detail)
- **Infill**: 15-20% (lattice walls are already hollow)
- **Walls**: 3-4 perimeters
- **Top/Bottom Layers**: 4-5 layers
- **Supports**: None needed!

### Tips:
- Lattice walls print beautifully without supports
- For large trays, consider disabling the Gridfinity base (flat bottom) if you don't need baseplate compatibility
- Print with brim if you have adhesion issues
- PETG or PLA work great - PETG for durability

## 🧵 Bambu Studio Project File (.3mf) (Optional)

If you print with Bambu Studio, a `.3mf` project file is nicer than a plain STL because it can preserve **plate layout** (and optional print settings).

- **Default printer**: Bambu Lab **P2S** (0.4 nozzle)
- **Default process**: 0.20mm Standard
- **Default filament**: Bambu PLA Basic

### If you just want to print

- Download the STL (or use the MakerWorld customizer) and slice normally in Bambu Studio.
- If you open a `.3mf` and your printer is different, Bambu Studio will prompt you to switch printer/profile.

### (Optional) Regenerate the example `.3mf` bundle from this repo

This is only needed if you’re rebuilding the included example bundle locally.

- Build the helper (once):

```bash
docker build -t gridfinity-bambu-studio-cli:02.05.00.67 docker/bambu-studio-cli
```

- Generate the `.3mf` bundle:

```bash
python3 generate_bambu_profiles.py
```

This writes:
- `bambu_profiles/all_examples_many_plates.3mf` (one example per plate, labeled)

Optional extras:
- `--packed` → also write `bambu_profiles/all_examples_packed.3mf`
- `--individual` → also write `bambu_profiles/<preset>.3mf`
- `--all` → export everything

## 📏 Sizing Guide

### Common Container Sizes:
- **Acrylic Paint Pots**: 28-35mm diameter
- **Citadel/Games Workshop Paint**: 26mm diameter
- **Spice Jars**: 40-50mm diameter
- **Pill Bottles**: 25-30mm diameter
- **AA Batteries**: 14.5mm diameter
- **AAA Batteries**: 10.5mm diameter
- **Marker Pens**: 12-15mm diameter

### Grid Size Reference:
- **1×1 = 42mm**: 1-2 small containers
- **2×2 = 84mm**: 4-6 medium containers
- **3×3 = 126mm**: 9-12 containers
- **Larger**: Scale up as needed!

Supports **half units** (`gridx`/`gridy` in 0.5 steps) for half-grid baseplates.

## 🔧 Advanced Features

- **Plain Bottom Mode**: Disable gridfinity base for simple flat-bottom organizer
- **Magnet Holes**: Add 6×2mm magnet holes for baseplate attachment (gridfinity mode)
- **Screw Holes**: M3 screw mounting option (gridfinity mode)
- **Corner Holes Only**: Faster printing when you only need magnets/screws in the corners
- **Packing Modes**: Auto or grid arrangement
- **Custom Holder Details**: Adjust rim thickness, taper, and recess depth

## 🎨 Design Notes

This design uses a **single-piece wall architecture** for the lattice pattern, ensuring:
- Clean manifold geometry
- Excellent print quality
- No layering artifacts
- Strong, reliable prints

The honeycomb pattern is created by subtracting hex holes from each wall face individually, with protected corner zones for structural integrity.

## 📝 Version History

### v3.0 - Multi-Variant Organizers
- Added **rectangular pocket** variant: `gridfinity-rect-pocket-tray.scad`
- Improved customizer usability: keep **object dimensions** at the top of each model
- Rect pockets: choose **rounded vs sharp inner corners** (with optional radius)
- Oversize objects no longer hard-fail: if a holder/pocket can’t fit the opening, the model falls back to **one centered cutout** (it will be clipped) instead of crashing
- Added build/test automation for MakerWorld-ready self-contained `.scad` files

### v2.0 - Lattice Walls Update
- Complete rewrite of lattice wall system
- Single-piece architecture for manifold geometry
- Adjustable bottom rim parameter
- Improved parameter organization
- Better default presets

### v1.0 - Initial Release
- Basic gridfinity cylinder holder
- Solid walls
- Customizable dimensions

## 🤝 Credits

Based on the excellent Gridfinity system by Zack Freedman.
Honeycomb pattern inspired by various parametric honeycomb libraries.

## 📄 License

This design is released under Creative Commons Attribution 4.0 International (CC BY 4.0).
You are free to use, modify, and distribute this design, even commercially, with attribution.

## 💬 Support

If you have questions or suggestions, feel free to leave a comment or remix!

**Happy Printing! 🎉**
