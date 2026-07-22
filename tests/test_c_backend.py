"""Build supported verify/*.ch via `chelis build --target c`, link with
the chelis runtime + OpenBLAS, run the binary, and assert stdout
matches a committed golden under verify/expected/<name>.txt.

This independent lane demonstrates that selected surfaces lower through the
production C backend even when the same feature also executes under
`chelis test`.

Each verify/<name>.ch is a self-contained module (no `Hello.*` prefix) so the
C-backend lane stays focused on one lowering surface at a time instead of
rebuilding the complete learner package for every golden.
"""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
VERIFY = REPO / "verify"
EXPECTED = VERIFY / "expected"


def discover() -> list[tuple[Path, Path]]:
    out: list[tuple[Path, Path]] = []
    for ch in sorted(VERIFY.glob("*.ch")):
        gold = EXPECTED / (ch.stem + ".txt")
        if gold.exists():
            out.append((ch, gold))
    return out


def supported_cases() -> list[tuple[Path, Path]]:
    return discover()


def link_flags() -> list[str]:
    return ["-lopenblas", "-lm", "-lpthread", "-ldl", "-fopenmp"]


@pytest.mark.parametrize("source,golden", supported_cases(), ids=lambda p: p.stem)
def test_c_backend_lowers_runs_matches_golden(source: Path, golden: Path) -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH")
    if shutil.which("gcc") is None:
        pytest.skip("gcc not on PATH")

    with tempfile.TemporaryDirectory() as tmp:
        # Copy outside the project so each golden proves one focused lowering
        # surface without repeatedly compiling the full Reef package.
        ch_copy = Path(tmp) / source.name
        ch_copy.write_text(source.read_text())
        out_dir = Path(tmp) / source.stem

        r = subprocess.run(
            ["chelis", "build", str(ch_copy), "--output", str(out_dir)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert r.returncode == 0, f"chelis build failed:\n{r.stdout}\n{r.stderr}"

        # The auto-link line chelis emits omits -lopenblas; we link manually
        # against the same .a it dropped in the output dir.
        c_file = out_dir / f"{source.stem}.c"
        bin_path = out_dir / source.stem
        link = subprocess.run(
            [
                "gcc",
                "-O2",
                "-march=native",
                "-fopenmp",
                str(c_file),
                f"-L{out_dir}",
                "-lchelis_runtime",
                *link_flags(),
                "-o",
                str(bin_path),
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        assert link.returncode == 0, f"gcc failed:\n{link.stdout}\n{link.stderr}"

        run = subprocess.run(
            [str(bin_path)], check=False, capture_output=True, text=True
        )
        assert (
            run.returncode == 0
        ), f"binary exited {run.returncode}:\n{run.stdout}\n{run.stderr}"

        actual = run.stdout.strip()
        expected = golden.read_text().strip()
        assert actual == expected, (
            f"output mismatch for {source.name}:\n"
            f"--- expected ---\n{expected}\n"
            f"--- actual ---\n{actual}"
        )
