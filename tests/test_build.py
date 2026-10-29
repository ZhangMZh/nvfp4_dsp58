# SPDX-License-Identifier: MIT
"""Build-runner regressions that do not require AMD tools."""

import contextlib
import hashlib
import importlib.util
import io
import json
import os
import sys
import tarfile
import tempfile
import unittest
import zipfile
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("dot16_runner", ROOT / "scripts/run.py")
runner = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runner)


class BuildTests(unittest.TestCase):
    def test_distribution_matches_fingerprinted_sources(self):
        expected = runner.sources("dist")
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            runner.source_dist(work)
            with tarfile.open(work / "nvfp4_dsp58-source.tar.gz") as archive:
                actual = {}
                for member in archive.getmembers():
                    name = str(Path(member.name).relative_to("nvfp4_dsp58"))
                    actual[name] = hashlib.sha256(archive.extractfile(member).read()).hexdigest()
        self.assertEqual(actual, expected)

    def test_ip_documentation_is_self_contained(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory) / "ip.zip"
            runner.package_docs(archive)
            with zipfile.ZipFile(archive) as package:
                self.assertEqual(set(package.namelist()), {"LICENSE", "README.md", "README.zh-CN.md"})
                for name in package.namelist():
                    self.assertEqual(package.read(name), (ROOT / name).read_bytes())

    def test_vivado_environment_does_not_require_executable_on_path(self):
        with patch.dict(os.environ, {"XILINX_VIVADO": "/opt/Vivado"}, clear=True):
            with patch.object(runner.shutil, "which", return_value=None) as which:
                self.assertEqual(runner.vivado_root(), Path("/opt/Vivado"))
                which.assert_not_called()

    def test_missing_vivado_has_actionable_error(self):
        with patch.dict(os.environ, {}, clear=True):
            with patch.object(runner.shutil, "which", return_value=None):
                with self.assertRaisesRegex(RuntimeError, "XILINX_VIVADO"):
                    runner.vivado_root()

    def test_source_failure_writes_failed_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch.object(sys, "argv", ["run.py", "dist", "--build", directory]):
                with patch.object(runner, "sources", side_effect=FileNotFoundError("missing source")):
                    with contextlib.redirect_stderr(io.StringIO()):
                        with self.assertRaises(SystemExit) as caught:
                            runner.main()
            receipt = json.loads((Path(directory) / "dist/receipt.json").read_text())
        self.assertEqual(caught.exception.code, 1)
        self.assertFalse(receipt["passed"])
        self.assertIn("missing source", receipt["error"])

    def test_stale_ip_adapter_is_rejected_before_its_implementation(self):
        for stale_kind in ("rtl", "hls"):
            with self.subTest(kind=stale_kind), tempfile.TemporaryDirectory() as directory:
                build = Path(directory)
                work = build / "ip-check"
                work.mkdir()
                for kind, adapter, relative in (
                    ("rtl", "nvfp4_dot16_axis", "rtl-ip/nvfp4_dot16_axis.zip"),
                    ("hls", "nvfp4_dot16_rtl", "hls-ip/project/solution/impl/ip/hls.zip"),
                ):
                    archive = build / relative
                    archive.parent.mkdir(parents=True)
                    files = [f"hdl/{module}.sv" for module in ("nvfp4_dot16", adapter)]
                    xml = (
                        '<component xmlns="http://www.spiritconsortium.org/XMLSchema/SPIRIT/1685-2009">'
                        f"<vendor>nvfp4.org</vendor><library>{kind}</library>"
                        "<name>test_ip</name><version>1.0</version><fileSets><fileSet>"
                        + "".join(f"<file><name>{name}</name></file>" for name in files)
                        + "</fileSet></fileSets></component>"
                    )
                    with zipfile.ZipFile(archive, "w") as package:
                        package.writestr("component.xml", xml)
                        for name in files:
                            content = (ROOT / "rtl/src" / Path(name).name).read_bytes()
                            if kind == stale_kind and Path(name).stem == adapter:
                                content += b"\n// stale adapter\n"
                            package.writestr(name, content)
                with patch.object(runner, "tcl_run") as implement:
                    with self.assertRaisesRegex(RuntimeError, "Packaged nvfp4_dot16_(axis|rtl)"):
                        runner.check_ip(work, build, "test-part", "3.333333")
                    self.assertEqual(implement.call_count, 0 if stale_kind == "rtl" else 1)


if __name__ == "__main__":
    unittest.main()
