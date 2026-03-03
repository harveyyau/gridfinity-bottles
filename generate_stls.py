#!/usr/bin/env python3
"""
Batch STL generator for gridfinity-cylinder-holder.scad
Uses the OpenSCAD customizer parameter sets in gridfinity-cylinder-holder.json.
"""

import argparse
import json
import os
import re
import subprocess
from pathlib import Path

# OpenSCAD binary (override with env var OPENSCAD_BIN)
OPENSCAD = os.environ.get("OPENSCAD_BIN", "openscad")
SCAD_FILE = Path("gridfinity-cylinder-holder.scad")
PARAMS_FILE = Path("gridfinity-cylinder-holder.json")
OUTPUT_DIR = Path("stl_exports")


def load_parameter_sets(params_file: Path) -> dict[str, dict[str, str]]:
    """Load OpenSCAD customizer parameterSets from a .json file."""
    data = json.loads(params_file.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("Params JSON root must be an object")
    sets = data.get("parameterSets")
    if not isinstance(sets, dict) or not sets:
        raise ValueError("Params JSON must contain a non-empty 'parameterSets' object")
    # Values are stored as strings; OpenSCAD interprets them using the model's variable types.
    out: dict[str, dict[str, str]] = {}
    for name, vals in sets.items():
        if isinstance(name, str) and isinstance(vals, dict):
            out[name] = {str(k): str(v) for k, v in vals.items()}
    if not out:
        raise ValueError("No valid parameter sets found in params JSON")
    return out


def slugify_filename(name: str) -> str:
    s = name.strip().lower()
    s = re.sub(r"[^\w]+", "_", s, flags=re.UNICODE)
    s = re.sub(r"_+", "_", s).strip("_")
    return s or "preset"


def generate_stl_from_param_set(
    *,
    openscad_bin: str,
    scad_file: Path,
    params_file: Path,
    param_set_name: str,
    output_file: Path,
    timeout_s: int,
    extra_args: list[str],
    dry_run: bool,
) -> bool:
    """Generate a single STL using -p/-P customizer parameter set selection."""
    cmd: list[str] = [
        openscad_bin,
        "-o",
        str(output_file),
        "-p",
        str(params_file),
        "-P",
        param_set_name,
        str(scad_file),
        *extra_args,
    ]

    print(f"Generating: {param_set_name}")
    if dry_run:
        print("  (dry-run) " + " ".join(cmd))
        return True

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_s)
        if result.returncode == 0:
            print(f"  ✓ {output_file}")
            return True
        print(f"  ✗ FAILED: {param_set_name}")
        if result.stderr:
            stderr = result.stderr.strip()
            print(f"    {stderr[-800:]}")
        return False
    except subprocess.TimeoutExpired:
        print(f"  ✗ TIMEOUT: {param_set_name}")
        return False
    except Exception as e:
        print(f"  ✗ ERROR: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(description="Batch-export STLs from OpenSCAD customizer parameter sets.")
    parser.add_argument("--openscad", default=OPENSCAD, help="OpenSCAD binary (or set OPENSCAD_BIN).")
    parser.add_argument("--scad", type=Path, default=SCAD_FILE, help="Path to .scad file.")
    parser.add_argument("--params", type=Path, default=PARAMS_FILE, help="Path to customizer .json file.")
    parser.add_argument("--output-dir", type=Path, default=OUTPUT_DIR, help="Directory to write STL files into.")
    parser.add_argument("--timeout", type=int, default=600, help="Per-export timeout in seconds.")
    parser.add_argument("--list", action="store_true", help="List available parameter sets and exit.")
    parser.add_argument(
        "--preset",
        action="append",
        default=[],
        help="Parameter set name to export (can be repeated). If omitted, exports all sets.",
    )
    parser.add_argument(
        "--extra-arg",
        action="append",
        default=[],
        help="Extra argument to pass to OpenSCAD (can be repeated).",
    )
    parser.add_argument("--dry-run", action="store_true", help="Print commands without running OpenSCAD.")
    args = parser.parse_args()

    param_sets = load_parameter_sets(args.params)
    available_names = list(param_sets.keys())

    if args.list:
        print("Available parameter sets:")
        for name in available_names:
            print(f"- {name}")
        return

    selected = args.preset if args.preset else available_names
    missing = [n for n in selected if n not in param_sets]
    if missing:
        raise SystemExit(
            "Unknown preset(s):\n"
            + "\n".join(f"- {n}" for n in missing)
            + "\n\nRun with --list to see available parameter sets."
        )

    args.output_dir.mkdir(exist_ok=True)

    print("Batch STL Generator")
    print("===================")
    print(f"OpenSCAD:  {args.openscad}")
    print(f"SCAD:      {args.scad}")
    print(f"Params:    {args.params}")
    print(f"Output:    {args.output_dir}/")
    print(f"Presets:   {len(selected)}")
    if args.dry_run:
        print("(dry-run enabled)")
    print()

    used_names: set[str] = set()
    failures = 0

    for name in selected:
        slug = slugify_filename(name)
        out_name = slug
        i = 2
        while out_name in used_names:
            out_name = f"{slug}_{i}"
            i += 1
        used_names.add(out_name)

        output_file = args.output_dir / f"{out_name}.stl"
        ok = generate_stl_from_param_set(
            openscad_bin=args.openscad,
            scad_file=args.scad,
            params_file=args.params,
            param_set_name=name,
            output_file=output_file,
            timeout_s=args.timeout,
            extra_args=args.extra_arg,
            dry_run=args.dry_run,
        )
        if not ok:
            failures += 1

    print()
    if failures:
        raise SystemExit(f"Done with errors: {failures} export(s) failed.")
    print(f"Done. Exported {len(selected)} STL(s) to {args.output_dir}/")


if __name__ == "__main__":
    main()
