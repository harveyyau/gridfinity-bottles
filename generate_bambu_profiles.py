#!/usr/bin/env python3
"""
Generate Bambu Studio .3mf "print profile" project files from exported STLs.

This script is designed to work on macOS by running the Bambu Studio CLI inside
the provided Docker image (workaround for native CLI crashes).

Outputs (by default) into ./bambu_profiles/:
- A many-plates bundle (one STL per plate), using Bambu's own plate-grid layout

Optional:
- A packed multi-plate bundle (auto-packing across as many plates as needed)
- One .3mf per STL in ./stl_exports/

No slicing/G-code is generated (avoids known slicer crashes).
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
import zipfile
from dataclasses import dataclass
from pathlib import Path
from typing import Callable


DEFAULT_DOCKER_IMAGE = "gridfinity-bambu-studio-cli:02.05.00.67"
DEFAULT_DOCKER_PLATFORM = "linux/amd64"

DEFAULT_STL_DIR = Path("stl_exports")
DEFAULT_OUT_DIR = Path("bambu_profiles")

DEFAULT_MACHINE = Path("bambu_settings/machine_bambu_p2s_0p4.json")
DEFAULT_PROCESS = Path("bambu_settings/process_0p20_standard_bbl_p2s.json")
DEFAULT_FILAMENT = Path("bambu_settings/filament_bambu_pla_basic_bbl_p2s.json")

NS_3MF_CORE = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"


@dataclass(frozen=True)
class BambuSettings:
    machine_json: Path
    process_json: Path
    filament_jsons: list[Path]


def _repo_root() -> Path:
    # Script is stored in repo root.
    return Path(__file__).resolve().parent


def _rel_to_repo(p: Path) -> str:
    return str(p.as_posix())


def _inside_work(p: Path) -> str:
    # Convert a repo-relative path to the container path.
    return "/work/" + _rel_to_repo(p)


def _run(cmd: list[str], *, timeout_s: int) -> None:
    res = subprocess.run(cmd, text=True, capture_output=True, timeout=timeout_s)
    if res.returncode != 0:
        msg = [
            "Command failed:",
            "  " + " ".join(cmd),
            f"Exit code: {res.returncode}",
        ]
        if res.stdout.strip():
            msg.append("--- stdout (tail) ---")
            msg.append(res.stdout.strip()[-2000:])
        if res.stderr.strip():
            msg.append("--- stderr (tail) ---")
            msg.append(res.stderr.strip()[-2000:])
        raise RuntimeError("\n".join(msg))


def _docker_bambu_cmd(
    *,
    image: str,
    platform: str,
    repo_root: Path,
    uid_gid: str | None,
) -> list[str]:
    cmd: list[str] = ["docker", "run", "--rm", "--platform", platform]
    if uid_gid:
        cmd.extend(["-u", uid_gid])
    cmd.extend(
        [
            "-e",
            "HOME=/tmp",
            "-e",
            "XDG_RUNTIME_DIR=/tmp",
            "-v",
            f"{str(repo_root)}:/work",
            "-w",
            "/work",
            image,
        ]
    )
    return cmd


def export_3mf(
    *,
    bambu_bin: str | None,
    docker_image: str | None,
    docker_platform: str,
    settings: BambuSettings,
    input_stls: list[Path],
    output_3mf: Path,
    orient: int,
    arrange: int,
    debug: int,
    timeout_s: int,
) -> None:
    if not input_stls:
        raise ValueError("No STL inputs provided")

    repo_root = _repo_root()

    # Validate settings exist (relative to repo root)
    for p in [settings.machine_json, settings.process_json, *settings.filament_jsons]:
        if not (repo_root / p).exists():
            raise FileNotFoundError(f"Missing settings file: {p}")

    # Ensure output directory exists
    (repo_root / output_3mf).parent.mkdir(parents=True, exist_ok=True)

    cmd: list[str]
    path_for_cli: Callable[[Path], str]
    stl_args: list[str]
    if docker_image:
        uid_gid: str | None = None
        try:
            uid = os.getuid()
            gid = os.getgid()
            uid_gid = f"{uid}:{gid}"
        except AttributeError:
            uid_gid = None

        cmd = _docker_bambu_cmd(
            image=docker_image,
            platform=docker_platform,
            repo_root=repo_root,
            uid_gid=uid_gid,
        )
        bambu_exe: list[str] = []
        path_for_cli = _inside_work
        stl_args = [_rel_to_repo(p) for p in input_stls]
    else:
        if not bambu_bin:
            raise ValueError("Provide either --docker-image or --bambu-bin")
        cmd = []
        bambu_exe = [bambu_bin]
        path_for_cli = lambda p: str((repo_root / p).resolve())
        stl_args = [str((repo_root / p).resolve()) for p in input_stls]

    bambu_args: list[str] = [
        *bambu_exe,
        "--debug",
        str(debug),
        "--orient",
        str(int(orient)),
        "--arrange",
        str(int(arrange)),
        "--ensure-on-bed",
        "--skip-useless-pick",
        "--load-settings",
        f"{path_for_cli(settings.machine_json)};{path_for_cli(settings.process_json)}",
        "--load-filaments",
        ";".join(path_for_cli(p) for p in settings.filament_jsons),
        "--export-3mf",
        path_for_cli(output_3mf),
        *stl_args,
    ]

    _run(cmd + bambu_args, timeout_s=timeout_s)


def _stl_name_to_label(name: str) -> str:
    base = Path(name).name
    if base.lower().endswith(".stl"):
        base = base[:-4]
    # Keep it simple & predictable; Bambu UI truncates long names anyway.
    return base.replace("_", " ")


def _rewrite_zip_with_replacements(zip_path: Path, replacements: dict[str, bytes]) -> None:
    tmp = zip_path.with_suffix(zip_path.suffix + ".tmp")
    with zipfile.ZipFile(zip_path, "r") as zin:
        with zipfile.ZipFile(tmp, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zout:
            for info in zin.infolist():
                data = replacements.get(info.filename)
                if data is None:
                    data = zin.read(info.filename)
                zout.writestr(info, data)
    tmp.replace(zip_path)


def _set_plate_names_in_3mf(three_mf: Path) -> None:
    """Populate per-plate 'plater_name' based on the model(s) on that plate."""
    with zipfile.ZipFile(three_mf, "r") as z:
        ms_bytes = z.read("Metadata/model_settings.config")

    ms_root = ET.fromstring(ms_bytes)

    # object_id -> STL name
    obj_name: dict[str, str] = {}
    for obj in ms_root.findall("object"):
        oid = obj.attrib.get("id")
        if not oid:
            continue
        for md in obj.findall("metadata"):
            if md.attrib.get("key") == "name":
                obj_name[oid] = md.attrib.get("value", "")
                break

    for idx, pl in enumerate(ms_root.findall("plate"), 1):
        # Gather object ids on this plate
        oids: list[str] = []
        for mi in pl.findall("model_instance"):
            for md in mi.findall("metadata"):
                if md.attrib.get("key") == "object_id":
                    oids.append(md.attrib.get("value", ""))
                    break
        labels = [_stl_name_to_label(obj_name.get(oid, oid)) for oid in oids if oid]
        labels = [l for l in labels if l]

        if not labels:
            plate_label = f"{idx:02d}"
        elif len(labels) == 1:
            plate_label = f"{idx:02d} - {labels[0]}"
        elif len(labels) == 2:
            plate_label = f"{idx:02d} - {labels[0]}, {labels[1]}"
        else:
            plate_label = f"{idx:02d} - {labels[0]}, {labels[1]}, +{len(labels) - 2} more"

        # Set/replace plate metadata
        md_el = None
        for md in pl.findall("metadata"):
            if md.attrib.get("key") == "plater_name":
                md_el = md
                break
        if md_el is None:
            md_el = ET.SubElement(pl, "metadata", {"key": "plater_name", "value": plate_label})
        else:
            md_el.attrib["value"] = plate_label

    new_ms = ET.tostring(ms_root, encoding="utf-8", xml_declaration=True)
    _rewrite_zip_with_replacements(three_mf, {"Metadata/model_settings.config": new_ms})


def _write_dummy_plate_filler_stl(path: Path, *, w: float = 200.0, d: float = 200.0, h: float = 0.4) -> None:
    # Centered rectangular prism; large enough that only one fits per plate.
    x0, x1 = -w / 2, w / 2
    y0, y1 = -d / 2, d / 2
    z0, z1 = 0.0, h

    def tri(n, a, b, c) -> str:
        return (
            f"  facet normal {n[0]} {n[1]} {n[2]}\n"
            f"    outer loop\n"
            f"      vertex {a[0]} {a[1]} {a[2]}\n"
            f"      vertex {b[0]} {b[1]} {b[2]}\n"
            f"      vertex {c[0]} {c[1]} {c[2]}\n"
            f"    endloop\n"
            f"  endfacet\n"
        )

    v000 = (x0, y0, z0)
    v001 = (x0, y0, z1)
    v010 = (x0, y1, z0)
    v011 = (x0, y1, z1)
    v100 = (x1, y0, z0)
    v101 = (x1, y0, z1)
    v110 = (x1, y1, z0)
    v111 = (x1, y1, z1)

    faces: list[str] = []
    faces += [tri((0, 0, -1), v000, v110, v100), tri((0, 0, -1), v000, v010, v110)]  # bottom
    faces += [tri((0, 0, 1), v001, v101, v111), tri((0, 0, 1), v001, v111, v011)]  # top
    faces += [tri((-1, 0, 0), v000, v001, v011), tri((-1, 0, 0), v000, v011, v010)]  # -x
    faces += [tri((1, 0, 0), v100, v110, v111), tri((1, 0, 0), v100, v111, v101)]  # +x
    faces += [tri((0, -1, 0), v000, v100, v101), tri((0, -1, 0), v000, v101, v001)]  # -y
    faces += [tri((0, 1, 0), v010, v011, v111), tri((0, 1, 0), v010, v111, v110)]  # +y

    stl = "solid plate_filler\n" + "".join(faces) + "endsolid plate_filler\n"
    path.write_text(stl, encoding="utf-8")


def _extract_plate_centers(layout_3mf: Path) -> list[tuple[float, float]]:
    with zipfile.ZipFile(layout_3mf, "r") as z:
        ms_root = ET.fromstring(z.read("Metadata/model_settings.config"))
        model_text = z.read("3D/3dmodel.model").decode("utf-8", errors="strict")

    item_re = re.compile(r'<item[^>]*objectid="(?P<oid>\d+)"[^>]*transform="(?P<tr>[^"]*)"')
    build_tr = {int(m.group("oid")): m.group("tr") for m in item_re.finditer(model_text)}

    centers: list[tuple[float, float]] = []
    for pl in ms_root.findall("plate"):
        mi = pl.find("model_instance")
        if mi is None:
            raise RuntimeError("Layout plate missing model_instance")
        oid: int | None = None
        for md in mi.findall("metadata"):
            if md.attrib.get("key") == "object_id":
                oid = int(md.attrib.get("value"))
                break
        if oid is None:
            raise RuntimeError("Layout model_instance missing object_id")
        tr = (build_tr.get(oid) or "").split()
        if len(tr) != 12:
            raise RuntimeError(f"Layout build item missing/invalid transform for objectid={oid}")
        centers.append((float(tr[9]), float(tr[10])))
    return centers


def _rewrite_many_plates_bundle(
    *,
    base_3mf: Path,
    out_3mf: Path,
    plate_centers: list[tuple[float, float]],
) -> None:
    with zipfile.ZipFile(base_3mf, "r") as zin:
        files = {name: zin.read(name) for name in zin.namelist()}

    ms_root = ET.fromstring(files["Metadata/model_settings.config"])

    # object_id -> stl filename (used for ordering)
    obj_name: dict[int, str] = {}
    for obj in ms_root.findall("object"):
        oid_s = obj.attrib.get("id")
        if not oid_s:
            continue
        name = None
        for md in obj.findall("metadata"):
            if md.attrib.get("key") == "name":
                name = md.attrib.get("value")
                break
        if name:
            obj_name[int(oid_s)] = name

    ordered_oids = sorted(obj_name.keys(), key=lambda oid: obj_name[oid].lower())
    n = len(ordered_oids)
    if len(plate_centers) < n:
        raise RuntimeError(f"Layout provides {len(plate_centers)} plates, but base has {n} objects")

    # Preserve identify_id where possible
    obj_identify: dict[int, str] = {}
    for pl in ms_root.findall("plate"):
        for mi in pl.findall("model_instance"):
            md = {m.attrib.get("key"): m.attrib.get("value") for m in mi.findall("metadata")}
            oid = md.get("object_id")
            ident = md.get("identify_id")
            if oid and ident:
                obj_identify[int(oid)] = ident

    # Remove existing plates
    for pl in list(ms_root.findall("plate")):
        ms_root.remove(pl)

    assemble = ms_root.find("assemble")
    if assemble is None:
        assemble = ET.SubElement(ms_root, "assemble")
    else:
        ms_root.remove(assemble)

    for i, oid in enumerate(ordered_oids, 1):
        pl = ET.Element("plate")
        for k, v in [
            ("plater_id", str(i)),
            ("plater_name", ""),
            ("locked", "false"),
            ("filament_map_mode", "Auto For Flush"),
            ("gcode_file", ""),
        ]:
            ET.SubElement(pl, "metadata", {"key": k, "value": v})
        mi = ET.SubElement(pl, "model_instance")
        ET.SubElement(mi, "metadata", {"key": "object_id", "value": str(oid)})
        ET.SubElement(mi, "metadata", {"key": "instance_id", "value": "0"})
        ET.SubElement(mi, "metadata", {"key": "identify_id", "value": str(obj_identify.get(oid, 1000 + i))})
        ms_root.append(pl)

    ms_root.append(assemble)
    files["Metadata/model_settings.config"] = ET.tostring(ms_root, encoding="utf-8", xml_declaration=True)

    # Update filament_sequence.json
    files["Metadata/filament_sequence.json"] = json.dumps(
        {f"plate_{i}": {"sequence": []} for i in range(1, n + 1)},
        separators=(",", ":"),
        ensure_ascii=False,
    ).encode("utf-8")

    # Patch 3D/3dmodel.model transforms (keep file's namespace/prefixes as-is).
    model_text = files["3D/3dmodel.model"].decode("utf-8", errors="strict")

    plate_index = {oid: i for i, oid in enumerate(ordered_oids, 1)}
    item_re = re.compile(r'(<item[^>]*objectid="(?P<oid>\d+)"[^>]*transform=")(?P<tr>[^"]*)(")')

    patched = 0

    def sub_fn(m: re.Match[str]) -> str:
        nonlocal patched
        oid = int(m.group("oid"))
        pi = plate_index.get(oid)
        if pi is None:
            return m.group(0)

        # Keep original Z translation (tz)
        tz = 0.0
        old_tr = m.group("tr").strip().split()
        if len(old_tr) == 12:
            try:
                tz = float(old_tr[11])
            except Exception:
                tz = 0.0

        tx, ty = plate_centers[pi - 1]
        new_tr = f"1 0 0 0 1 0 0 0 1 {tx:g} {ty:g} {tz:g}"
        patched += 1
        return m.group(1) + new_tr + m.group(4)

    model_text2 = item_re.sub(sub_fn, model_text)
    if patched != n:
        raise RuntimeError(f"Patched {patched} build items, expected {n}")

    files["3D/3dmodel.model"] = model_text2.encode("utf-8")

    out_3mf.parent.mkdir(parents=True, exist_ok=True)
    if out_3mf.exists():
        out_3mf.unlink()
    with zipfile.ZipFile(out_3mf, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zout:
        for name, data in files.items():
            zout.writestr(name, data)


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate Bambu Studio .3mf profiles from exported STLs.")
    parser.add_argument("--stl-dir", type=Path, default=DEFAULT_STL_DIR, help="Directory containing STL exports.")
    parser.add_argument("--out-dir", type=Path, default=DEFAULT_OUT_DIR, help="Directory to write .3mf files into.")

    bambu_group = parser.add_mutually_exclusive_group()
    bambu_group.add_argument("--docker-image", default=DEFAULT_DOCKER_IMAGE, help="Docker image containing Bambu Studio CLI.")
    bambu_group.add_argument("--bambu-bin", default=None, help="Path to local bambu-studio CLI binary (instead of Docker).")
    parser.add_argument("--docker-platform", default=DEFAULT_DOCKER_PLATFORM, help="Docker platform (default: linux/amd64).")

    parser.add_argument("--machine-json", type=Path, default=DEFAULT_MACHINE, help="Machine settings JSON.")
    parser.add_argument("--process-json", type=Path, default=DEFAULT_PROCESS, help="Process settings JSON.")
    parser.add_argument("--filament-json", type=Path, action="append", default=[DEFAULT_FILAMENT], help="Filament settings JSON (repeatable).")

    parser.add_argument("--timeout", type=int, default=600, help="Timeout (seconds) per Bambu CLI invocation.")
    parser.add_argument("--debug", type=int, default=1, help="Bambu CLI debug level (0-5).")
    parser.add_argument("--skip-existing", action="store_true", help="Skip outputs that already exist.")
    parser.add_argument("--no-plate-labels", action="store_true", help="Do not set per-plate names in exported .3mf files.")
    parser.add_argument(
        "--label-only",
        action="store_true",
        help="Only update per-plate names in existing .3mf files (no exporting).",
    )

    parser.add_argument(
        "--many-plates",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Export the one-STL-per-plate bundle .3mf (default: enabled).",
    )
    parser.add_argument(
        "--packed",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="Also export the packed multi-plate bundle .3mf (default: disabled).",
    )
    parser.add_argument(
        "--individual",
        action=argparse.BooleanOptionalAction,
        default=False,
        help="Also export one .3mf per STL (default: disabled).",
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Export everything (many-plates + packed + individual).",
    )
    parser.add_argument("--packed-name", default="all_examples_packed.3mf", help="Filename for the packed bundle.")
    parser.add_argument("--many-plates-name", default="all_examples_many_plates.3mf", help="Filename for the many-plates bundle.")

    args = parser.parse_args()
    if args.all:
        args.many_plates = True
        args.packed = True
        args.individual = True

    repo_root = _repo_root()
    stl_dir = repo_root / args.stl_dir
    out_dir = repo_root / args.out_dir

    settings = BambuSettings(
        machine_json=args.machine_json,
        process_json=args.process_json,
        filament_jsons=list(args.filament_json),
    )

    stls = sorted(p.relative_to(repo_root) for p in stl_dir.glob("*.stl"))
    if not stls:
        raise SystemExit(f"No STLs found in {args.stl_dir}/. Run generate_stls.py first.")

    out_dir.mkdir(parents=True, exist_ok=True)

    docker_image = args.docker_image if args.bambu_bin is None else None
    bambu_bin = args.bambu_bin

    if args.label_only:
        if args.no_plate_labels:
            return 0
        for p in sorted((repo_root / args.out_dir).glob("*.3mf")):
            _set_plate_names_in_3mf(p)
        return 0

    if args.individual:
        for stl in stls:
            out_3mf = args.out_dir / f"{stl.stem}.3mf"
            out_abs = repo_root / out_3mf
            if args.skip_existing and out_abs.exists():
                if not args.no_plate_labels:
                    _set_plate_names_in_3mf(out_abs)
                continue
            export_3mf(
                bambu_bin=bambu_bin,
                docker_image=docker_image,
                docker_platform=args.docker_platform,
                settings=settings,
                input_stls=[stl],
                output_3mf=out_3mf,
                orient=0,
                arrange=1,
                debug=args.debug,
                timeout_s=args.timeout,
            )
            if not args.no_plate_labels:
                _set_plate_names_in_3mf(out_abs)

    packed_out = args.out_dir / args.packed_name
    many_out = args.out_dir / args.many_plates_name
    packed_abs = repo_root / packed_out
    many_abs = repo_root / many_out

    if args.packed:
        if args.skip_existing and packed_abs.exists():
            if not args.no_plate_labels:
                _set_plate_names_in_3mf(packed_abs)
        else:
            export_3mf(
                bambu_bin=bambu_bin,
                docker_image=docker_image,
                docker_platform=args.docker_platform,
                settings=settings,
                input_stls=stls,
                output_3mf=packed_out,
                orient=0,
                arrange=1,
                debug=args.debug,
                timeout_s=args.timeout,
            )
            if not args.no_plate_labels:
                _set_plate_names_in_3mf(packed_abs)

    if args.many_plates:
        if args.skip_existing and many_abs.exists():
            if not args.no_plate_labels:
                _set_plate_names_in_3mf(many_abs)
            return 0

        # Build the many-plates bundle by:
        # - exporting a packed bundle (intermediate, temp unless --packed is enabled)
        # - exporting a temporary layout bundle with one dummy STL per plate (to learn plate centers)
        # - rewriting the packed bundle into one STL per plate using those centers
        with tempfile.TemporaryDirectory(prefix="bambu_bundle_", dir=str(out_dir)) as td:
            tmp_dir = Path(td)
            # Intermediate packed bundle
            if args.packed:
                base_packed = packed_out
            else:
                base_packed = Path(tmp_dir.relative_to(repo_root)) / "packed_tmp.3mf"
                export_3mf(
                    bambu_bin=bambu_bin,
                    docker_image=docker_image,
                    docker_platform=args.docker_platform,
                    settings=settings,
                    input_stls=stls,
                    output_3mf=base_packed,
                    orient=0,
                    arrange=1,
                    debug=args.debug,
                    timeout_s=args.timeout,
                )

            # Layout bundle (dummy STLs)
            tmp_stl_dir = tmp_dir / "dummy_stls"
            tmp_stl_dir.mkdir(parents=True, exist_ok=True)
            for i in range(1, len(stls) + 1):
                _write_dummy_plate_filler_stl(tmp_stl_dir / f"plate_{i:03d}.stl")

            layout_3mf = tmp_dir / "layout.3mf"
            layout_rel = layout_3mf.relative_to(repo_root)
            export_3mf(
                bambu_bin=bambu_bin,
                docker_image=docker_image,
                docker_platform=args.docker_platform,
                settings=settings,
                input_stls=[p.relative_to(repo_root) for p in sorted(tmp_stl_dir.glob("*.stl"))],
                output_3mf=Path(layout_rel),
                orient=0,
                arrange=1,
                debug=args.debug,
                timeout_s=args.timeout,
            )

            centers = _extract_plate_centers(repo_root / layout_rel)
            _rewrite_many_plates_bundle(
                base_3mf=repo_root / base_packed,
                out_3mf=many_abs,
                plate_centers=centers,
            )
            if not args.no_plate_labels:
                _set_plate_names_in_3mf(many_abs)

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        print("Interrupted.", file=sys.stderr)
        raise
