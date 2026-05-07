"""Build a representative subset of examples via `chelis build --target c`
and verify the emitted source carries `// span:` markers tying back to
Surf — the audit-chain invariant.
"""

from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path

import pytest

from .conftest import REPO_ROOT, EXAMPLES

TARGETS = [
    EXAMPLES / "01_language_basics" / "01_hello_tensor.ch",
    EXAMPLES / "01_language_basics" / "08_grad_basic.ch",
    EXAMPLES / "06_capstone" / "transformer_block" / "block.ch",
    EXAMPLES / "06_capstone" / "black_scholes_greeks" / "black_scholes.ch",
]


@pytest.mark.parametrize("path", TARGETS, ids=lambda p: str(p.relative_to(REPO_ROOT)))
def test_c_backend_emits_spans(path: Path) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        out_dir = Path(tmpdir)
        r = subprocess.run(
            ["chelis", "build", "--target", "c", "--out-dir", str(out_dir), str(path)],
            check=False, capture_output=True, text=True,
        )
        assert r.returncode == 0, f"build failed:\n{r.stdout}\n{r.stderr}"
        c_files = list(out_dir.rglob("*.c"))
        assert c_files, "no .c output produced"
        assert any("// span:" in c.read_text() for c in c_files), (
            "emitted C contains no `// span:` markers; audit chain is broken"
        )
