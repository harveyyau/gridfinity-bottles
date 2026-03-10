#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


VARIANT_OUTPUTS: list[Path] = [
    REPO_ROOT / "gridfinity-cylinder-holder.scad",
    REPO_ROOT / "gridfinity-rect-pocket-tray.scad",
]


def _run(cmd: list[str], *, timeout_s: int) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout_s)


def _has_includes(scad_text: str) -> bool:
    for line in scad_text.splitlines():
        s = line.strip()
        if s.startswith("include <") or s.startswith("use <"):
            return True
    return False


def main() -> int:
    parser = argparse.ArgumentParser(description="Test MakerWorld-ready .scad variants by exporting STLs.")
    parser.add_argument("--openscad", default="openscad", help="OpenSCAD binary (default: openscad).")
    parser.add_argument("--timeout", type=int, default=600, help="Per-export timeout in seconds.")
    parser.add_argument(
        "--no-build",
        action="store_true",
        help="Skip running tools/build_makerworld_variants.py before testing.",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=REPO_ROOT / "dist" / "test_stl_exports",
        help="Directory to write test STL files into.",
    )
    args = parser.parse_args()

    if not args.no_build:
        build_cmd = [sys.executable, str(REPO_ROOT / "tools" / "build_makerworld_variants.py")]
        r = _run(build_cmd, timeout_s=args.timeout)
        sys.stdout.write(r.stdout)
        sys.stderr.write(r.stderr)
        if r.returncode != 0:
            return r.returncode

    args.out_dir.mkdir(parents=True, exist_ok=True)

    ok = True
    for scad in VARIANT_OUTPUTS:
        if not scad.exists():
            print(f"Missing built SCAD: {scad}", file=sys.stderr)
            ok = False
            continue

        text = scad.read_text(encoding="utf-8")
        if _has_includes(text):
            print(f"Not self-contained (still has include/use): {scad}", file=sys.stderr)
            ok = False

        out_stl = args.out_dir / (scad.stem + ".stl")
        cmd = [args.openscad, "-o", str(out_stl), str(scad)]
        print(f"Exporting STL: {out_stl.name}")
        try:
            r = _run(cmd, timeout_s=args.timeout)
        except subprocess.TimeoutExpired:
            print(f"TIMEOUT: {scad}", file=sys.stderr)
            ok = False
            continue

        combined = (r.stdout or "") + "\n" + (r.stderr or "")
        if r.returncode != 0:
            print(f"FAILED: {scad} (exit {r.returncode})", file=sys.stderr)
            tail = combined.strip()[-2000:]
            if tail:
                print(tail, file=sys.stderr)
            ok = False
            continue

        if "ERROR:" in combined:
            print(f"ERROR output during export: {scad}", file=sys.stderr)
            tail = combined.strip()[-2000:]
            if tail:
                print(tail, file=sys.stderr)
            ok = False
            continue

        if "Status:" in combined and "NoError" not in combined:
            print(f"Non-NoError status during export: {scad}", file=sys.stderr)
            tail = combined.strip()[-2000:]
            if tail:
                print(tail, file=sys.stderr)
            ok = False
            continue

    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())

