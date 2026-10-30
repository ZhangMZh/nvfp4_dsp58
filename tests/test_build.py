# SPDX-License-Identifier: MIT
"""Build-runner regressions that do not require AMD tools."""

import importlib.util
import os
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
    def test_ip_documentation_is_self_contained(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory) / "ip.zip"
            runner.package_docs(archive)
            with zipfile.ZipFile(archive) as package:
                self.assertEqual(set(package.namelist()), {"LICENSE", "README.md"})
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


if __name__ == "__main__":
    unittest.main()
