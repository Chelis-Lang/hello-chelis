"""Build each verify/*.ch via `chelis build --target c`, link with the
chelis runtime + OpenBLAS, run the binary, and compare its tensor structure
and numeric values with verify/expected/<name>.txt.

Each verify/<name>.ch is a standalone module (no `Hello.*` prefix) built
from a temporary directory. verify/ is not a declared source root of the
package, and building from inside the package lowers the whole package,
which fails on the capstone Black-Scholes Greeks (chelis#2379).
"""

from __future__ import annotations

import re
import shutil
import subprocess
import tempfile
from pathlib import Path

import pytest

REPO = Path(__file__).resolve().parent.parent
VERIFY = REPO / "verify"
EXPECTED = VERIFY / "expected"
TENSOR_LINE = re.compile(
    r"^(?P<label>[A-Za-z_][A-Za-z0-9_]*) = tensor\(shape=\[(?P<shape>[^]]*)\], "
    r"data=\[(?P<data>[^]]*)\]\)$"
)


def parse_tensor_output(text: str) -> list[tuple[str, tuple[int, ...], list[float]]]:
    records = []
    for line in text.strip().splitlines():
        match = TENSOR_LINE.fullmatch(line.strip())
        if match is None:
            raise ValueError(f"unexpected C-backend output line: {line!r}")
        shape_text = match.group("shape").strip()
        data_text = match.group("data").strip()
        shape = tuple(
            int(value.strip()) for value in shape_text.split(",") if value.strip()
        )
        data = [float(value.strip()) for value in data_text.split(",") if value.strip()]
        records.append((match.group("label"), shape, data))
    return records


def assert_tensor_output_matches(actual: str, expected: str) -> None:
    actual_records = parse_tensor_output(actual)
    expected_records = parse_tensor_output(expected)
    assert len(actual_records) == len(expected_records)
    for actual_record, expected_record in zip(
        actual_records, expected_records, strict=True
    ):
        actual_label, actual_shape, actual_data = actual_record
        expected_label, expected_shape, expected_data = expected_record
        assert actual_label == expected_label
        assert actual_shape == expected_shape
        assert actual_data == pytest.approx(expected_data, rel=1e-6, abs=1e-7)


def test_tensor_output_comparison_accepts_equivalent_f32_renderings() -> None:
    concise = "ys = tensor(shape=[3], data=[0.11920292, 0.5, 0.880797])"
    precise = (
        "ys = tensor(shape=[3], data=[0.1192029193043709, 0.5, 0.8807970285415649])"
    )
    assert_tensor_output_matches(concise, precise)


def test_tensor_output_comparison_rejects_shape_drift() -> None:
    with pytest.raises(AssertionError):
        assert_tensor_output_matches(
            "ys = tensor(shape=[2], data=[1.0, 2.0])",
            "ys = tensor(shape=[1, 2], data=[1.0, 2.0])",
        )


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
        # Copy outside the project so each build lowers only this C example.
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

        assert_tensor_output_matches(run.stdout, golden.read_text())
