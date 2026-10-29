#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Small command runner for the native Vivado/Vitis Tcl flows."""

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tests"))
from reference import write_vectors  # noqa: E402

DOC_FILES = ("LICENSE", "README.md", "README.zh-CN.md")
SOURCE_DIRS = ("rtl", "hls", "tests", "scripts")
DIST_FILES = ("Makefile", ".gitignore", ".clang-format", "AGENTS.md", *DOC_FILES)


def run(command, work, name, marker=None):
    print(f"START {name}: {' '.join(map(str, command))}", flush=True)
    env = os.environ.copy()
    if shutil.which("gcc"):
        crt = subprocess.check_output(["gcc", "-print-file-name=crt1.o"], text=True).strip()
        if Path(crt).is_file():
            env["LIBRARY_PATH"] = str(Path(crt).parent) + (
                ":" + env["LIBRARY_PATH"] if env.get("LIBRARY_PATH") else ""
            )
    with (work / f"{name}.log").open("w") as log:
        result = subprocess.run(
            list(map(str, command)), cwd=work, env=env, stdout=log, stderr=subprocess.STDOUT
        )
    text = (work / f"{name}.log").read_text(errors="replace")
    if result.returncode or (marker and marker not in text):
        print(text[-8000:], file=sys.stderr)
        raise RuntimeError(f"{name} failed: {work / (name + '.log')}")
    print(f"PASS {name}", flush=True)


def tcl_run(script, arguments, work, tool, name):
    words = " ".join("{" + str(v) + "}" for v in arguments)
    launcher = work / f"{name}.tcl"
    launcher.write_text(f"set argv [list {words}]\nsource {{{script}}}\n")
    if tool == "vivado":
        command = [tool, "-mode", "batch", "-nojournal", "-source", launcher]
    else:
        command = [tool, "--mode", "hls", "--tcl", launcher]
    run(command, work, name, "DOT16_FLOW_PASS")


def sources(task):
    # Fingerprint the files actually used by this target. A packaging-only
    # script change must not invalidate an independent arithmetic simulation.
    paths = {ROOT / "Makefile", ROOT / "scripts/run.py"}
    if task == "test":
        paths.update((ROOT / "tests").glob("*.py"))
    if task.startswith("rtl-") or task.startswith("hls-"):
        paths.update((ROOT / "rtl/src").glob("*.sv"))
    if task == "rtl-sim" or task.startswith("hls-"):
        paths.add(ROOT / "tests/reference.py")
    if task in ("rtl-sim", "hls-cosim"):
        paths.add(ROOT / "rtl/tb/tb_dot16.sv")
    if task.startswith("hls-"):
        paths.update(p for p in (ROOT / "hls").rglob("*") if p.is_file())
    if task in ("rtl-impl", "ip-check"):
        paths.add(ROOT / "rtl/scripts/physical.tcl")
        paths.add(ROOT / "rtl/scripts" / ("implement.tcl" if task == "rtl-impl" else "check_ip.tcl"))
    if task == "rtl-ip":
        paths.add(ROOT / "rtl/scripts/package.tcl")
    if task in ("rtl-ip", "hls-ip", "dist"):
        paths.update(ROOT / name for name in DOC_FILES)
    if task == "ip-check":
        paths.update((ROOT / "rtl/src").glob("*.sv"))
    if task == "dist":
        paths.update(ROOT / name for name in DIST_FILES)
        for directory in SOURCE_DIRS:
            paths.update(p for p in (ROOT / directory).rglob("*") if p.is_file())
    return {
        str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(paths)
        if "__pycache__" not in p.parts
    }


def vivado_root():
    directory = os.environ.get("XILINX_VIVADO")
    if directory:
        return Path(directory)
    executable = shutil.which("vivado")
    if executable is None:
        raise RuntimeError("Set XILINX_VIVADO or add vivado to PATH before RTL simulation")
    return Path(executable).resolve().parents[1]


def rtl_sim(work, hls_rtl=None):
    count = write_vectors(work / "vectors.mem")
    vivado = vivado_root()
    for kind in ("hls",) if hls_rtl else ("axis", "fifo"):
        sim = work / kind
        sim.mkdir(exist_ok=True)
        files = (
            sorted(hls_rtl.glob("*.v")) + sorted(hls_rtl.glob("*.sv"))
            if hls_rtl
            else sorted((ROOT / "rtl/src").glob("*.sv"))
        )
        defines = ["-d", "TEST_HLS"] if kind == "hls" else (["-d", "TEST_FIFO"] if kind == "fifo" else [])
        run(
            [
                "xvlog",
                "--sv",
                *defines,
                *files,
                ROOT / "rtl/tb/tb_dot16.sv",
                vivado / "data/verilog/src/glbl.v",
            ],
            sim,
            "compile",
        )
        run(["xelab", "tb_dot16", "glbl", "-L", "unisims_ver", "-s", "sim", "-mt", "2"], sim, "elaborate")
        run(
            [
                "xsim",
                "sim",
                "-runall",
                "--testplusarg",
                f"vectors={work / 'vectors.mem'}",
                "--testplusarg",
                f"count={count}",
            ],
            sim,
            "simulate",
            "PASS dot16",
        )


def hls_run(work, mode, part, period):
    write_vectors(work / "vectors.mem")
    descriptor = {
        "c_function_name": "nvfp4_dot16_rtl",
        "rtl_top_module_name": "nvfp4_dot16_rtl",
        "c_files": [
            {"c_file": str(ROOT / "hls/src/model.cpp"), "cflag": f"-std=c++14 -I{ROOT / 'hls/include'}"}
        ],
        "rtl_files": [str(ROOT / f"rtl/src/{name}.sv") for name in ("nvfp4_dot16", "nvfp4_dot16_rtl")],
        "c_parameters": [
            {
                "c_name": "input",
                "c_port_direction": "in",
                "rtl_ports": {
                    "FIFO_empty_flag": "input_empty_n",
                    "FIFO_read_enable": "input_read",
                    "FIFO_data_read_in": "input_dout",
                },
            },
            {
                "c_name": "output",
                "c_port_direction": "out",
                "rtl_ports": {
                    "FIFO_full_flag": "output_full_n",
                    "FIFO_write_enable": "output_write",
                    "FIFO_data_write_out": "output_din",
                },
            },
        ],
        "rtl_common_signal": {
            "module_clock": "ap_clk",
            "module_reset": "ap_rst",
            "module_clock_enable": "ap_ce",
            "ap_ctrl_chain_protocol_idle": "",
            "ap_ctrl_chain_protocol_start": "",
            "ap_ctrl_chain_protocol_ready": "",
            "ap_ctrl_chain_protocol_done": "",
            "ap_ctrl_chain_protocol_continue": "",
        },
        "rtl_performance": {"latency": "6", "II": "1"},
        "rtl_resource_usage": {"FF": "436", "LUT": "120", "BRAM": "0", "URAM": "0", "DSP": "4"},
    }
    # FF/LUT estimates come from isolated implementation plus FIFO control.
    # Actual routed utilization remains authoritative for each integration.
    (work / "dot16.json").write_text(json.dumps(descriptor, indent=2) + "\n")
    tcl_run(ROOT / "hls/scripts/run.tcl", [ROOT, work, part, period, mode], work, "vitis-run", mode)
    if mode == "cosim":
        # Independently drive the synthesized external AXIS ports to measure
        # throughput/latency and reset behavior, not just HLS schedule estimates.
        rtl_sim(work, work / "project/solution/syn/verilog")
    if mode == "ip":
        for archive in (work / "project/solution/impl/ip").glob("*.zip"):
            package_docs(archive)


def package_docs(archive):
    with zipfile.ZipFile(archive, "a", compression=zipfile.ZIP_DEFLATED) as out:
        for name in DOC_FILES:
            out.write(ROOT / name, name)


def check_ip(work, build, part, period):
    archives = [build / "rtl-ip/nvfp4_dot16_axis.zip"]
    archives.extend(sorted((build / "hls-ip/project/solution/impl/ip").glob("*.zip")))
    if len(archives) != 2 or not all(p.is_file() for p in archives):
        raise RuntimeError("Run rtl-ip and hls-ip before ip-check")
    ns = {"s": "http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009"}
    audits = []
    # A fresh temporary directory deliberately separates imported IP from sources.
    with tempfile.TemporaryDirectory(prefix="nvfp4-ip-relocated-") as temporary:
        for kind, archive in zip(("rtl", "hls"), archives):
            archive_sha = hashlib.sha256(archive.read_bytes()).hexdigest()
            package = Path(temporary) / kind
            package.mkdir()
            with zipfile.ZipFile(archive) as inp:
                for name in inp.namelist():
                    if Path(name).is_absolute() or ".." in Path(name).parts:
                        raise RuntimeError(f"Nonportable archive entry: {name}")
                inp.extractall(package)
            xml = package / "component.xml"
            tree = ET.parse(xml).getroot()
            vlnv = ":".join(
                tree.findtext(f"s:{key}", namespaces=ns) for key in ("vendor", "library", "name", "version")
            )
            files = {n.text for n in tree.findall(".//s:file/s:name", ns)}
            file_hashes = {}
            for name in files:
                path = package / name
                if (
                    Path(name).is_absolute()
                    or not path.resolve().is_relative_to(package.resolve())
                    or not path.is_file()
                ):
                    raise RuntimeError(f"Package references missing/external file: {name}")
                file_hashes[name] = hashlib.sha256(path.read_bytes()).hexdigest()
            adapter = "nvfp4_dot16_axis" if kind == "rtl" else "nvfp4_dot16_rtl"
            for module in ("nvfp4_dot16", adapter):
                matches = list(package.rglob(f"{module}.sv"))
                source = ROOT / "rtl/src" / f"{module}.sv"
                if len(matches) != 1 or matches[0].read_bytes() != source.read_bytes():
                    raise RuntimeError(f"Packaged {module} differs from current RTL")
            out = work / kind
            out.mkdir(exist_ok=True)
            tcl_run(
                ROOT / "rtl/scripts/check_ip.tcl",
                [ROOT, package, out, part, period, vlnv],
                out,
                "vivado",
                "reimport",
            )
            if hashlib.sha256(archive.read_bytes()).hexdigest() != archive_sha:
                raise RuntimeError("IP archive changed during implementation")
            audits.append(
                {
                    "kind": kind,
                    "vlnv": vlnv,
                    "archive_sha256": archive_sha,
                    "packaged_file_sha256": file_hashes,
                    "passed": True,
                }
            )
    (work / "packages.json").write_text(json.dumps(audits, indent=2) + "\n")


def source_dist(work):
    files = [ROOT / name for name in DIST_FILES]
    for directory in SOURCE_DIRS:
        files.extend(p for p in (ROOT / directory).rglob("*") if p.is_file() and "__pycache__" not in p.parts)
    with tarfile.open(work / "nvfp4_dsp58-source.tar.gz", "w:gz") as archive:
        for path in sorted(files):
            archive.add(path, arcname=str(Path("nvfp4_dsp58") / path.relative_to(ROOT)), recursive=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "task",
        choices=[
            "test",
            "rtl-sim",
            "rtl-impl",
            "rtl-ip",
            "hls-csim",
            "hls-synth",
            "hls-cosim",
            "hls-ip",
            "ip-check",
            "dist",
        ],
    )
    parser.add_argument("--build", type=Path, default=ROOT / "build")
    parser.add_argument("--part", default="xcv80-lsva4737-2MHP-e-S")
    parser.add_argument("--period", default="3.333333")
    args = parser.parse_args()
    work = args.build.resolve() / args.task
    work.mkdir(parents=True, exist_ok=True)
    started = time.monotonic()
    receipt = {"task": args.task, "part": args.part, "period_ns": args.period, "sources": {}, "passed": False}
    try:
        initial = sources(args.task)
        receipt["sources"] = initial
        if args.task == "test":
            run(
                [sys.executable, "-m", "unittest", "discover", "-s", ROOT / "tests", "-v"],
                work,
                "reference",
                "OK",
            )
        elif args.task == "rtl-sim":
            rtl_sim(work)
        elif args.task == "rtl-impl":
            tcl_run(
                ROOT / "rtl/scripts/implement.tcl",
                [ROOT / "rtl/src", "nvfp4_dot16_axis", work, args.part, args.period],
                work,
                "vivado",
                "implement",
            )
        elif args.task == "rtl-ip":
            tcl_run(
                ROOT / "rtl/scripts/package.tcl",
                [ROOT, work, args.part, args.period],
                work,
                "vivado",
                "package",
            )
            package_docs(work / "nvfp4_dot16_axis.zip")
        elif args.task == "ip-check":
            check_ip(work, args.build.resolve(), args.part, args.period)
        elif args.task == "dist":
            source_dist(work)
        else:
            hls_run(work, args.task.removeprefix("hls-"), args.part, args.period)
        if sources(args.task) != initial:
            raise RuntimeError("Sources changed during this run; rerun for coherent evidence")
        receipt["passed"] = True
    except Exception as exc:
        receipt["error"] = str(exc)
        print(str(exc), file=sys.stderr)
    receipt["seconds"] = round(time.monotonic() - started, 2)
    (work / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
    raise SystemExit(0 if receipt["passed"] else 1)


if __name__ == "__main__":
    main()
