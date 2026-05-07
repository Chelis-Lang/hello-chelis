#!/usr/bin/env python3
"""Run every example under examples/ through `chelis check`, optionally also
through `chelis eval` and `chelis build --target c`.

Usage:
    python3 scripts/run_examples.py --check        # type-check only (default)
    python3 scripts/run_examples.py --eval         # also run via the IR evaluator
    python3 scripts/run_examples.py --build        # also run the C backend
    python3 scripts/run_examples.py --all          # check + eval + build
    python3 scripts/run_examples.py --filter coral # only the coral examples

Per-example expected outputs live in tests/expected/<relative-path>.json.
The harness in tests/test_chelis_eval.py is the gating CI lane;
this script is the fast local sweep.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = REPO_ROOT / "examples"


@dataclass
class ExampleResult:
    path: Path
    check_ok: bool
    eval_ok: bool | None
    build_ok: bool | None
    fitness: float | None
    duration_s: float


def find_examples(filter_substring: str | None) -> list[Path]:
    out: list[Path] = []
    for p in sorted(EXAMPLES.rglob("*.ch")):
        rel = str(p.relative_to(REPO_ROOT))
        if filter_substring and filter_substring not in rel:
            continue
        out.append(p)
    return out


def run_check(path: Path) -> tuple[bool, float | None]:
    """Run `chelis check --json <path>`, return (ok, fitness)."""
    r = subprocess.run(
        ["chelis", "check", "--json", str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    fitness: float | None = None
    try:
        report = json.loads(r.stdout)
        fitness = float(report.get("score", 0.0))
        ok = bool(report.get("errors", []) == []) and r.returncode == 0
    except json.JSONDecodeError:
        ok = r.returncode == 0
    return ok, fitness


def run_eval(path: Path) -> bool:
    r = subprocess.run(
        ["chelis", "eval", str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    return r.returncode == 0


def run_build(path: Path) -> bool:
    out_dir = REPO_ROOT / "build" / path.with_suffix("").relative_to(EXAMPLES)
    out_dir.mkdir(parents=True, exist_ok=True)
    r = subprocess.run(
        ["chelis", "build", "--target", "c", "--out-dir", str(out_dir), str(path)],
        check=False,
        capture_output=True,
        text=True,
    )
    return r.returncode == 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", default=True, help=argparse.SUPPRESS)
    parser.add_argument("--eval", dest="do_eval", action="store_true", help="also run via the IR evaluator")
    parser.add_argument("--build", dest="do_build", action="store_true", help="also run the C backend")
    parser.add_argument("--all", action="store_true", help="check + eval + build")
    parser.add_argument("--filter", default=None, help="only examples whose path contains this substring")
    parser.add_argument("--quiet", action="store_true")
    args = parser.parse_args()

    if args.all:
        args.do_eval = True
        args.do_build = True

    examples = find_examples(args.filter)
    if not examples:
        print("no examples found", file=sys.stderr)
        return 1

    results: list[ExampleResult] = []
    failures: list[str] = []
    for ex in examples:
        rel = ex.relative_to(REPO_ROOT)
        t0 = time.monotonic()
        check_ok, fitness = run_check(ex)
        eval_ok: bool | None = None
        build_ok: bool | None = None
        if check_ok and args.do_eval:
            eval_ok = run_eval(ex)
        if check_ok and args.do_build:
            build_ok = run_build(ex)
        elapsed = time.monotonic() - t0
        results.append(ExampleResult(
            path=rel,
            check_ok=check_ok,
            eval_ok=eval_ok,
            build_ok=build_ok,
            fitness=fitness,
            duration_s=elapsed,
        ))
        ok = check_ok and (eval_ok in (None, True)) and (build_ok in (None, True))
        marker = "OK " if ok else "FAIL"
        score = f"fit={fitness:.2f}" if fitness is not None else "fit=?   "
        if not args.quiet or not ok:
            print(f"  {marker}  {rel}  {score}  {elapsed:.2f}s", flush=True)
        if not ok:
            failures.append(str(rel))

    print(f"\n{len(results) - len(failures)}/{len(results)} examples passed")
    if failures:
        print("failures:")
        for f in failures:
            print(f"  - {f}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
