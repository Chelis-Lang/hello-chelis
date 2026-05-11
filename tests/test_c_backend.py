"""Build supported verify/*.ch via `chelis build --target c`, link with
the chelis runtime + OpenBLAS, run the binary, and assert stdout
matches a committed golden under verify/expected/<name>.txt.

This is the lane that demonstrates native C lowering where v0.7.6
supports it, and locks known v0.7.6 symbolic-dimension codegen panics
as expected failures until upstream fixes them. The IR evaluator
(`chelis test`) still has a narrower primitive set on v0.7.6; the C
backend covers the supported lowering examples.

Each verify/<name>.ch is a self-contained module (no `Hello.*` prefix)
because `chelis build` rejects projects that contain `with seed(...)`
anywhere in the source tree.
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
KNOWN_C_CODEGEN_PANICS = {
    "grad_works",
    "relu_lowers",
    "relu_then_sigmoid",
    "sigmoid_lowers",
}


def discover() -> list[tuple[Path, Path]]:
    out: list[tuple[Path, Path]] = []
    for ch in sorted(VERIFY.glob("*.ch")):
        gold = EXPECTED / (ch.stem + ".txt")
        if gold.exists():
            out.append((ch, gold))
    return out


def supported_cases() -> list[tuple[Path, Path]]:
    return [
        (source, golden)
        for source, golden in discover()
        if source.stem not in KNOWN_C_CODEGEN_PANICS
    ]


def known_codegen_panic_cases() -> list[Path]:
    return [
        source
        for source, _golden in discover()
        if source.stem in KNOWN_C_CODEGEN_PANICS
    ]


def link_flags() -> list[str]:
    return ["-lopenblas", "-lm", "-lpthread", "-ldl", "-fopenmp"]


@pytest.mark.parametrize("source,golden", supported_cases(), ids=lambda p: p.stem)
def test_c_backend_lowers_runs_matches_golden(source: Path, golden: Path) -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH")
    if shutil.which("gcc") is None:
        pytest.skip("gcc not on PATH")

    with tempfile.TemporaryDirectory() as tmp:
        # Copy outside the project so `chelis build` doesn't pull the
        # full src tree (which would trip `with seed` rejection).
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


@pytest.mark.parametrize("source", known_codegen_panic_cases(), ids=lambda p: p.stem)
def test_c_backend_known_symbolic_dim_codegen_panic(source: Path) -> None:
    if shutil.which("chelis") is None:
        pytest.skip("chelis not on PATH")

    with tempfile.TemporaryDirectory() as tmp:
        ch_copy = Path(tmp) / source.name
        ch_copy.write_text(source.read_text())
        out_dir = Path(tmp) / source.stem

        result = subprocess.run(
            ["chelis", "build", str(ch_copy), "--output", str(out_dir)],
            check=False,
            capture_output=True,
            text=True,
        )
        assert result.returncode != 0
        assert "internal compiler error: symbolic dim" in result.stderr
        assert "no Load input declares it" in result.stderr
