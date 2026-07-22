#!/usr/bin/env python3
"""Materialize learner negatives into the toolchain-native tests_neg suite."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SOURCE = REPO / "tests" / "negative"
TARGET = REPO / "tests_neg" / "learner"
HEADER_RE = re.compile(r"^--\s*chelis-expect-fail:\s*(\S+)", re.MULTILINE)
DIAGNOSTICS = {
    "DimensionMismatch": "dimension mismatch",
    "PrecisionMismatch": "precision mismatch",
    "UnboundVariable": "unbound variable: missing",
}
GENERATED_HEADER = (
    "-- GENERATED from {source}; run python3 scripts/sync_negative_tests.py\n"
)


def expected_files() -> dict[Path, str]:
    expected: dict[Path, str] = {}
    for source in sorted(SOURCE.glob("*.ch")):
        text = source.read_text()
        match = HEADER_RE.search(text)
        if match is None:
            raise ValueError(
                f"{source.relative_to(REPO)}: missing chelis-expect-fail header"
            )
        kind = match.group(1)
        diagnostic = DIAGNOSTICS.get(kind)
        if diagnostic is None:
            raise ValueError(
                f"{source.relative_to(REPO)}: no stable diagnostic mapping for {kind}"
            )
        relative = source.relative_to(REPO)
        module_suffix = "_".join(part.capitalize() for part in source.stem.split("_"))
        guard_name = f"test_neg_{source.stem}"
        generated = (
            GENERATED_HEADER.format(source=relative)
            + f"module Hello.TestsNeg.Learner.{module_suffix}\n"
            + text
            + f'def {guard_name}() -> unit = test_assert(false, "{source.stem} unexpectedly compiled")\n'
        )
        expected[TARGET / source.name] = generated
        expected[TARGET / f"{source.stem}.expect"] = (
            f"{diagnostic}\nsource: {relative}; synchronized by scripts/sync_negative_tests.py\n"
        )
    return expected


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    try:
        expected = expected_files()
    except ValueError as exc:
        print(exc, file=sys.stderr)
        return 1

    stale: list[Path] = []
    for path, content in expected.items():
        if not path.exists() or path.read_text() != content:
            stale.append(path)
        if not args.check:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)

    extras = sorted(
        path for path in TARGET.glob("*") if path.is_file() and path not in expected
    )
    if args.check:
        stale.extend(extras)
    else:
        for path in extras:
            path.unlink()

    if args.check and stale:
        print("tests_neg learner mirrors are stale:", file=sys.stderr)
        for path in stale:
            print(f"  {path.relative_to(REPO)}", file=sys.stderr)
        print("Run `python3 scripts/sync_negative_tests.py`.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
