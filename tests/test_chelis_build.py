"""Build a representative subset of examples via `chelis build --target c`,
verify the emitted source carries `// span:` comments tying back to Surf.

Building every example would multiply CI time without adding signal.
We pick one example per directory as the build smoke test plus the
capstones, where the audit chain matters most.
"""

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

import pytest

from .conftest import REPO_ROOT, EXAMPLES

BUILD_TARGETS: list[Path] = [
    EXAMPLES / "01_language_basics" / "01_hello_tensor.ch",
    EXAMPLES / "01_language_basics" / "08_grad_basic.ch",
    EXAMPLES / "02_std" / "activations_norms.ch",
    EXAMPLES / "06_capstone" / "transformer_block" / "block.ch",
    EXAMPLES / "06_capstone" / "black_scholes_greeks" / "black_scholes.ch",
]


@pytest.mark.parametrize("path", BUILD_TARGETS, ids=lambda p: str(p.relative_to(REPO_ROOT)))
def test_c_backend_builds_with_spans(path: Path) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        out_dir = Path(tmpdir)
        r = subprocess.run(
            ["chelis", "build", "--target", "c", "--out-dir", str(out_dir), str(path)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert r.returncode == 0, (
            f"chelis build {path} failed:\n"
            f"stdout:\n{r.stdout}\nstderr:\n{r.stderr}"
        )
        c_files = list(out_dir.rglob("*.c"))
        assert c_files, f"no C output produced for {path}"
        any_span_marker = False
        for c in c_files:
            text = c.read_text()
            if "// span:" in text:
                any_span_marker = True
                break
        assert any_span_marker, (
            f"emitted C for {path} contains no `// span:` markers — the "
            "audit chain is broken"
        )
