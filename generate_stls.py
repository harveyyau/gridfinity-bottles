#!/usr/bin/env python3
"""
Batch STL generator for gridfinity.scad
Generates multiple preset configurations for testing/distribution
"""

import subprocess
import sys
from pathlib import Path

# OpenSCAD binary path (adjust if needed)
OPENSCAD = "/opt/homebrew/Caskroom/openscad/2021.01/OpenSCAD-2021.01.app/Contents/MacOS/OpenSCAD"
SCAD_FILE = "gridfinity.scad"
OUTPUT_DIR = Path("stl_exports")

# Define your presets here
PRESETS = [
    {
        "name": "AA_battery_holder_2x2",
        "params": {
            "gridx": 2,
            "gridy": 2,
            "cylinder_diameter": 14.5,
            "holder_clearance": 0.5,
            "holder_rim_height": 50,
            "enable_tray_wall": "false",
            "enable_stacking": "false",
        }
    },
    {
        "name": "paint_pot_1x1_stackable",
        "params": {
            "gridx": 1,
            "gridy": 1,
            "cylinder_diameter": 32,
            "holder_clearance": 0.5,
            "holder_rim_height": 15,
            "enable_tray_wall": "true",
            "tray_wall_thickness": 2.0,
            "object_height": 40,
            "enable_stacking": "true",
            "stacking_clearance": 0.3,
            "enable_raised_floor": "false",
        }
    },
    {
        "name": "spice_jar_2x2_walls",
        "params": {
            "gridx": 2,
            "gridy": 2,
            "cylinder_diameter": 45,
            "holder_clearance": 0.5,
            "holder_rim_height": 15,
            "enable_tray_wall": "true",
            "tray_wall_thickness": 2.5,
            "object_height": 80,
            "enable_stacking": "false",
            "enable_raised_floor": "true",
            "raised_floor_height": 15,
        }
    },
    # Add more presets here
]


def build_openscad_args(preset):
    """Convert preset dict to OpenSCAD -D arguments"""
    args = []
    for key, val in preset["params"].items():
        # Handle boolean strings and numbers
        if isinstance(val, bool):
            val_str = "true" if val else "false"
        elif isinstance(val, str):
            val_str = val
        else:
            val_str = str(val)
        args.extend(["-D", f"{key}={val_str}"])
    return args


def generate_stl(preset, output_dir):
    """Generate a single STL from a preset"""
    output_file = output_dir / f"{preset['name']}.stl"
    
    cmd = [
        OPENSCAD,
        "-o", str(output_file),
        SCAD_FILE,
    ] + build_openscad_args(preset)
    
    print(f"Generating {preset['name']}...")
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        if result.returncode == 0:
            print(f"  ✓ {output_file}")
        else:
            print(f"  ✗ FAILED: {preset['name']}")
            if result.stderr:
                print(f"     {result.stderr[:200]}")
    except subprocess.TimeoutExpired:
        print(f"  ✗ TIMEOUT: {preset['name']}")
    except Exception as e:
        print(f"  ✗ ERROR: {e}")


def main():
    # Create output directory
    OUTPUT_DIR.mkdir(exist_ok=True)
    
    print(f"Batch STL Generator")
    print(f"===================")
    print(f"OpenSCAD: {OPENSCAD}")
    print(f"Input:    {SCAD_FILE}")
    print(f"Output:   {OUTPUT_DIR}/")
    print(f"Presets:  {len(PRESETS)}")
    print()
    
    # Generate all presets
    for preset in PRESETS:
        generate_stl(preset, OUTPUT_DIR)
    
    print()
    print(f"Done. Exported {len(PRESETS)} STLs to {OUTPUT_DIR}/")


if __name__ == "__main__":
    main()
