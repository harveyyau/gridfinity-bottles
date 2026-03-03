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
# Bambu Studio CLI binary (override with env var BAMBU_STUDIO_BIN)
BAMBU_STUDIO = os.environ.get("BAMBU_STUDIO_BIN", "bambu-studio")
SCAD_FILE = Path("gridfinity-cylinder-holder.scad")
PARAMS_FILE = Path("gridfinity-cylinder-holder.json")
OUTPUT_DIR = Path("stl_exports")
BAMBU_OUTPUT_DIR = Path("bambu_profiles")


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


def generate_bambu_3mf_from_stl(
    *,
    bambu_studio_bin: str,
    input_stl: Path,
    output_file: Path,
    timeout_s: int,
    template_3mf: Path | None,
    machine_json: Path | None,
    process_json: Path | None,
    filament_jsons: list[Path],
    orient: bool,
    arrange: int,
    slice_plate: int,
    debug_level: int,
    extra_args: list[str],
    dry_run: bool,
) -> bool:
    """
    Generate a Bambu Studio project (.3mf) from an STL using the Bambu Studio CLI.

    For MakerWorld, a .3mf created by Bambu Studio is the "print profile" format.
    """
    if template_3mf is None and (machine_json is None or process_json is None):
        raise ValueError(
            "To export Bambu .3mf you must provide either --bambu-template, or both --bambu-machine and --bambu-process."
        )

    if template_3mf is not None and not template_3mf.exists():
        raise FileNotFoundError(f"Bambu template not found: {template_3mf}")
    if machine_json is not None and not machine_json.exists():
        raise FileNotFoundError(f"Bambu machine settings not found: {machine_json}")
    if process_json is not None and not process_json.exists():
        raise FileNotFoundError(f"Bambu process settings not found: {process_json}")
    for f in filament_jsons:
        if not f.exists():
            raise FileNotFoundError(f"Bambu filament settings not found: {f}")

    file_args: list[str] = []
    if template_3mf is not None:
        file_args.append(str(template_3mf))
    file_args.append(str(input_stl))

    cmd: list[str] = [bambu_studio_bin]
    # Newer Bambu Studio builds expect an explicit value for --orient.
    cmd.extend(["--orient", "1" if orient else "0"])
    cmd.extend(["--arrange", str(arrange)])
    if machine_json is not None and process_json is not None:
        cmd.extend(["--load-settings", f"{machine_json};{process_json}"])
    if filament_jsons:
        cmd.extend(["--load-filaments", ";".join(str(p) for p in filament_jsons)])
    cmd.extend(
        [
            "--slice",
            str(slice_plate),
            "--debug",
            str(debug_level),
            "--export-3mf",
            str(output_file),
            *extra_args,
            *file_args,
        ]
    )

    print(f"Generating Bambu .3mf: {output_file.name}")
    if dry_run:
        print("  (dry-run) " + " ".join(cmd))
        return True

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_s)
        if result.returncode == 0:
            print(f"  ✓ {output_file}")
            return True
        print(f"  ✗ FAILED: {output_file.name}")
        if result.stderr:
            stderr = result.stderr.strip()
            print(f"    {stderr[-800:]}")
        return False
    except subprocess.TimeoutExpired:
        print(f"  ✗ TIMEOUT: {output_file.name}")
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
    parser.add_argument("--export-bambu-3mf", action="store_true", help="Also export Bambu Studio .3mf print profiles.")
    parser.add_argument("--bambu-studio", default=BAMBU_STUDIO, help="Bambu Studio CLI binary (or set BAMBU_STUDIO_BIN).")
    parser.add_argument(
        "--bambu-output-dir",
        type=Path,
        default=BAMBU_OUTPUT_DIR,
        help="Directory to write .3mf print profiles into.",
    )
    parser.add_argument(
        "--bambu-template",
        type=Path,
        default=None,
        help="Optional template .3mf to provide printer/filament/process presets (recommended for MakerWorld).",
    )
    parser.add_argument("--bambu-machine", type=Path, default=None, help="Machine settings JSON (full config).")
    parser.add_argument("--bambu-process", type=Path, default=None, help="Process settings JSON (full config).")
    parser.add_argument(
        "--bambu-filament",
        action="append",
        default=[],
        type=Path,
        help="Filament settings JSON (full config). Can be repeated.",
    )
    parser.add_argument("--bambu-orient", action=argparse.BooleanOptionalAction, default=True, help="Orient models.")
    parser.add_argument("--bambu-arrange", type=int, default=1, help="Arrange option: 0 disable, 1 enable.")
    parser.add_argument("--bambu-slice", type=int, default=0, help="Slice plate index (0 = all plates).")
    parser.add_argument("--bambu-debug", type=int, default=2, help="Bambu Studio debug level (0-5).")
    parser.add_argument(
        "--bambu-extra-arg",
        action="append",
        default=[],
        help="Extra argument to pass to Bambu Studio (can be repeated).",
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
    if args.export_bambu_3mf:
        print(f"Bambu:     {args.bambu_studio}")
        print(f"Bambu out: {args.bambu_output_dir}/")
    if args.dry_run:
        print("(dry-run enabled)")
    print()

    used_names: set[str] = set()
    failures = 0
    bambu_failures = 0

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

        if args.export_bambu_3mf and ok:
            args.bambu_output_dir.mkdir(exist_ok=True)
            bambu_output_file = args.bambu_output_dir / f"{out_name}.3mf"
            try:
                ok_3mf = generate_bambu_3mf_from_stl(
                    bambu_studio_bin=args.bambu_studio,
                    input_stl=output_file,
                    output_file=bambu_output_file,
                    timeout_s=args.timeout,
                    template_3mf=args.bambu_template,
                    machine_json=args.bambu_machine,
                    process_json=args.bambu_process,
                    filament_jsons=list(args.bambu_filament),
                    orient=bool(args.bambu_orient),
                    arrange=int(args.bambu_arrange),
                    slice_plate=int(args.bambu_slice),
                    debug_level=int(args.bambu_debug),
                    extra_args=list(args.bambu_extra_arg),
                    dry_run=args.dry_run,
                )
            except Exception as e:
                ok_3mf = False
                print(f"  ✗ ERROR exporting .3mf: {e}")
            if not ok_3mf:
                bambu_failures += 1

    print()
    if failures:
        raise SystemExit(f"Done with errors: {failures} export(s) failed.")
    if bambu_failures:
        raise SystemExit(f"Done with errors: {bambu_failures} Bambu .3mf export(s) failed.")
    if args.export_bambu_3mf:
        print(f"Done. Exported {len(selected)} STL(s) to {args.output_dir}/ and {len(selected)} .3mf file(s) to {args.bambu_output_dir}/")
    else:
        print(f"Done. Exported {len(selected)} STL(s) to {args.output_dir}/")


if __name__ == "__main__":
    main()
