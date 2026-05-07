# Architecture

This page is a companion to the
[Chelis primer](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/chelis_canonical_reference.md).
It maps the language's pipeline onto the directories in this repo.

## The compiler pipeline (recap)

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
                          (chelis eval)                    (chelis build)
                                                                   |
                                                              Executable
```

Every example in this repo is exercised by both arms:

- `chelis check` runs the front end (parse, type-check, effects, linearity)
  and emits a fitness score with structured errors.
- `chelis eval` runs the IR evaluator in-process — the fast interactive path.
- `chelis build --target c` lowers, generates C with span comments, and
  links against the chelis runtime + OpenBLAS + libgomp.

## Surface organization

```text
examples/
├── 01_language_basics/        compiler + std only; no shell deps
├── 02_std/                    chelis-std (Std.*)
├── 03_coral/                  Coral.*  -> dataframes
├── 04_nautilus/               Nautilus.*  -> scipy-style numerics
├── 05_octant/                 octant CLI: LaTeX -> Deep
└── 06_capstone/               multi-shell integrations
```

The split mirrors the dependency graph: each directory only imports what's
in it or to its left. `01_language_basics` brings in std implicitly. `03_coral`
imports `Std.*` and `Coral.*`. `04_nautilus` imports `Std.*` and
`Nautilus.*`. `05_octant` is unique — Octant is a separate translator binary,
not an importable library — so its examples are paired `.tex` / `.ch` files
where the `.ch` is the verified output of `octant translate`. The capstones
in `06_capstone` import across all four.

## Why not one monolithic example?

Two reasons:

1. **Each Chelis feature has a narrow blast radius.** A bug in the
   linearity checker doesn't break dimension inference, and a missing
   `cross_entropy` builtin doesn't break ADTs. Splitting the corpus by
   feature is what lets you tell, when something fails, which subsystem
   regressed.
2. **The compiler's fitness score is per-program.** A single 800-line
   monolith would emit one number that fails to localize. 40 small programs
   yield 40 scores plus 40 typed-AST snapshots, which is the actual signal
   shape the substrate is engineered around.

## Testing model

**Chelis has its own native test runner**, and that's the primary gate.
Every example in this repo defines one or more

```chelis-surf
def test_*() -> unit ! { Test } = ...
```

functions, with assertions written via `Std.Test.assert_*`. The
`! { Test }` effect propagates to any caller — production entry points
declared with `! {}` get a type error if a Test-effect call sneaks in,
which is what makes the boundary load-bearing. `chelis test examples/`
discovers and runs every `test_*` and exits non-zero if any assertion
fails.

Python under `tests/` is **fallback orchestration only**. It covers what
the native runner doesn't:

- Programs that must be *rejected* (negative examples for
  use-after-consume, precision mismatch, dim mismatch).
- `octant translate <tex>` regeneration matching the committed `.ch`.
- `// span:` audit-chain markers in the C backend's emitted source.
- Surf↔Deep round-trip identity (nightly only).

If a check can be expressed as a Chelis-native test, it should be — Python
is for the parts of the trust stack that require shelling out to a
non-Chelis tool.

## How a single example is structured

A typical example file:

```chelis-surf
module Hello.Std.ActivationsNorms

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

def relu_then_sigmoid(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> relu |> sigmoid

def test_relu_sigmoid_on_zeros() -> unit ! { Test } = {
  zeros = to_tensor([0.0, 0.0, 0.0])
  out = relu_then_sigmoid(zeros)
  expected = to_tensor([0.5, 0.5, 0.5])
  assert_close_tensor(out, expected, 1e-6, "relu_then_sigmoid_on_zeros")
}
```

The pattern: one `module` per file; small, well-named definitions; one or
more `test_*() -> unit ! { Test }` functions. Every example is its own
self-contained `chelis check` target.

The capstones break this pattern slightly — they have more than one file
in a folder, and a `README.md` per capstone explaining the integration.

## Audit chain

When you `chelis build --target c`, every line of generated C carries a
`// span: <id>` comment pointing at a Surf source location. The harness
verifies this in `tests/test_chelis_build.py` — each compiled example's
emitted C is grepped for span markers, and the absence of any is a test
failure. This is the audit trail the primer talks about, made into a
checkable invariant rather than a marketing claim.
