# Architecture

This page is a companion to the
[Chelis primer](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/chelis_canonical_reference.md).
It maps the language's pipeline onto the directories in this repo.

## The compiler pipeline

```text
.ch (Surf)  --desugar-->  .dp (Deep)  --parse-->  AST
                                                   |
                                       infer (HM + dims)
                                                   |
                                              annotated Deep
                                                   |
                                       effect infer / check
                                                   |
                                          linearity check
                                                   |
                                                lower
                                                   |
                                              RISC DAG
                                                   |
                                  +----------------+----------------+
                                  |                                 |
                          IR Evaluator                       C codegen
                          (chelis test, eval)              (chelis build)
                                                                   |
                                                              Executable
```

Three execution paths share the front-end (parse / type / dim /
effect / linearity) but diverge after lowering:

- **`chelis check`** runs the front end and emits a JSON fitness
  report with structured errors. Most permissive lane.
- **`chelis test`, `chelis eval`** run the IR evaluator in-process.
  Fast iteration, but a narrower primitive set on v0.7.6.
- **`chelis build --target c`** lowers, generates C with `// span:`
  audit-chain comments, and links against `libchelis_runtime.a` +
  OpenBLAS + libgomp. Production path.

A program can pass `chelis check` and fail at either runtime, or pass
in one runtime and fail in the other. The corpus is structured around
that fact — every test runs in the lane that supports it. Verbatim
gap inventory in [`discrepancies.md`](discrepancies.md).

## Directory layout — feature-by-feature, not monolithic

```text
src/
├── basics/     compiler + chelis-std only       Hello.Basics.*
├── std/        Std.* surfaces                   Hello.Std.*
├── coral/      Coral.* dataframes               Hello.Coral.*
├── nautilus/   Nautilus.* scipy-equivalent      Hello.Nautilus.*
└── capstone/   multi-shell integrations         Hello.Capstone.*

tests/
├── basics/, std/, coral/, nautilus/, capstone/  Hello.Tests.*.*
└── negative/                                    expected-fail .ch files

verify/                                          project-free C-backend programs
octant/                                          .tex + machine-generated triple
```

The `src/` split mirrors the dependency graph: each directory only
imports from its left-hand neighbors plus `chelis-std`. `coral`
imports `Std.*` and `Coral.*`. `nautilus` is independent of `coral`.
The capstones in `src/capstone/` import across the code-import shells.

`octant/` lives at the repo root because Octant is a CLI translator,
not an importable Chelis library — its outputs aren't `Hello.*`
modules, just raw Deep + decompiled Surf snippets.

## Why feature-by-feature

1. **Each Chelis feature has a narrow blast radius.** A bug in
   linearity doesn't break dimension inference; a regressed
   `cross_entropy` doesn't break ADTs. Splitting the corpus by
   feature lets you triage which subsystem regressed when something
   fails.
2. **The compiler's fitness score is per-program.** A single
   800-line monolith would emit one fitness number that fails to
   localize. 50+ small programs each yield a separate score plus a
   typed-AST snapshot, which is the signal shape the substrate is
   engineered around.

## How a single example is structured

`src/<area>/<name>.ch`:

```chelis-surf
module Hello.Std.ActivationsNorms

import Std.Tensor.Construct (to_tensor)

export (relu_then_sigmoid)

def relu_then_sigmoid(x: tensor[n, f32]) -> tensor[n, f32] =
  sigmoid(relu(x))
```

`tests/<area>/<name>.ch`:

```chelis-surf
module Hello.Tests.Std.ActivationsNorms

import Hello.Std.ActivationsNorms (relu_then_sigmoid)
import Std.Test (assert_close_tensor)

def test_relu_sigmoid_on_zeros() -> unit ! { Test } = {
  zeros = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])
  expected = to_tensor([cast(0.5, f32), cast(0.5, f32), cast(0.5, f32)])
  assert_close_tensor(relu_then_sigmoid(zeros), expected, cast(1e-6, f32), "rs_zeros")
}
```

The pattern: source modules in `src/`, test modules in `tests/`,
1:1 file mapping. Each test function returns `unit ! { Test }`; the
`! { Test }` effect propagates to callers, so any production entry
point declared `! {}` rejects test-effect calls at compile time.

`chelis test tests/ --jobs auto` runs the native runtime suite with
node-local concurrency. Use `chelis test tests/ --jobs 1` when a serial
debugging run is easier to read. Full-corpus behavioral coverage is
completed by the Deep drift, negative, Octant, c-earchin, and C-backend
pytest lanes.

## How equivalence is enforced

Every `.ch` has a sibling `.dp` machine-generated by `chelis deep`.
The two surfaces are kept in sync by:

```sh
python3 scripts/regen_deep.py            # regenerate
python3 scripts/regen_deep.py --check    # CI drift assertion
```

CI's [`tests/test_surf_deep_equivalence.py`](../tests/test_surf_deep_equivalence.py)
runs the `--check` mode and fails on any divergence. See
[`surf-and-deep.md`](surf-and-deep.md) for the design rationale.

## Testing model summary

| Lane | What it runs | Surface |
|---|---|---|
| `chelis lint .` | non-blocking nomenclature inventory per `spec/01-nomenclature.md` | every `.ch` |
| `chelis check src/<file>.ch` | front-end (parse/type/dim/effect/linearity) | per file |
| `chelis test tests/ --jobs auto` | runtime assertions via the IR evaluator | full native suite |
| `pytest tests/test_surf_deep_equivalence.py` | `.dp` matches `chelis deep <ch>` | every Surf file |
| `pytest tests/test_c_backend.py` | `chelis build` + link + run + golden-diff | `verify/*.ch` |
| `pytest tests/test_octant_pairs.py` | LaTeX → Deep → Surf round-trip | every `octant/*.tex` |
| `pytest tests/test_c_earchin_artifacts.py` | EARS → Deep property witnesses prove with span diagnostics | finance-options fixtures |
| `pytest tests/test_negative_examples.py` | programs that must be rejected | `tests/negative/*.ch` |

Each is non-overlapping and gates on a different invariant.

## Audit chain

When you `chelis build --target c`, every line of generated C carries
a `// span: <id>` comment pointing at a Surf source location. This is
the audit trail the primer talks about, made into a checkable
invariant by the C-backend test lane in
[`tests/test_c_backend.py`](../tests/test_c_backend.py): each
verified program is built, linked, run, and the stdout golden-diffed
against `verify/expected/<name>.txt`. If lowering ever drops a span
or breaks the runtime semantics, the golden mismatches.
