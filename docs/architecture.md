# Architecture

How the Chelis compiler pipeline maps onto the directories in this repo. The
language itself is described in the
[Chelis primer](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/chelis_canonical_reference.md).

## The compiler pipeline

```text
.ch (Surf)  --desugar-->  .dp (Deep)  --parse-->  AST
                                                   |
                                  type and dimension inference
                                                   |
                                        effect inference/check
                                                   |
                                           linearity check
                                                   |
                                                 lower
                                                   |
                                               RISC DAG
                                                   |
                                  +----------------+----------------+
                                  |                                 |
                            IR evaluator                        C codegen
                       (chelis test, eval)                   (chelis build)
                                                                    |
                                                    gcc + libchelis_runtime + OpenBLAS
```

Three commands share the front end and diverge after lowering:

- **`chelis check`** runs the front end and prints a JSON report with
  structured errors. Pointed at any file in a package, it checks the whole
  package.
- **`chelis test` and `chelis eval`** run the IR evaluator in-process. This
  is how the runtime assertions under `tests/` execute.
- **`chelis build --target c`** lowers to C with `// span:` comments that link
  the output back to its Surf source. You compile and link it
  yourself against `libchelis_runtime.a` and OpenBLAS.

The evaluator and the C backend do not accept exactly the same programs.
Where they differ in a way that affects this corpus, the difference is listed
under Known limitations in the [README](../README.md) and tracked in
[`UPSTREAM_BUGS.md`](UPSTREAM_BUGS.md).

## Directory layout

```text
src/
├── basics/     language features; chelis-std only    Hello.Basics.*
├── std/        chelis-std and school surfaces         Hello.Std.*
├── coral/      Coral dataframes                       Hello.Coral.*
├── nautilus/   Nautilus numerical methods             Hello.Nautilus.*
└── capstone/   examples combining several packages    Hello.Capstone.*

tests/          one test module per src module         Hello.Tests.*
tests_neg/      programs the checker must reject
verify/         standalone programs compiled to C
octant/         LaTeX inputs and their generated outputs
c-earchin/      EARS requirements and their generated witnesses
```

Each `src/` folder imports only `chelis-std` plus the package it tours; the
capstones import across packages. `octant/` and `c-earchin/` sit outside
`src/` because their contents are translator outputs, not modules of this
package.

The corpus is split by feature so that a regression points at one
subsystem. A broken linearity check fails `linearity.ch`, not the whole
tree, and each small program gets its own `chelis check` score.

## How one example is structured

A source module, `src/basics/hellotensor.ch`:

```chelis-surf
module Hello.Basics.HelloTensor
export (add_vec)
def add_vec[n](x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = add(x, y)
```

and its test, `tests/basics/hellotensor.ch`:

```chelis-surf
module Hello.Tests.Basics.HelloTensor
import Hello.Basics.HelloTensor (add_vec)
import Std.Test (assert_close_tensor)
def test_add_vec() -> unit ! { Test } = {
  a = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  b = to_tensor([cast(4.0, f32), cast(5.0, f32), cast(6.0, f32)])
  expected = to_tensor([cast(5.0, f32), cast(7.0, f32), cast(9.0, f32)])
  assert_close_tensor(add_vec(a, b), expected, cast(1e-6, f32), "add_vec_3")
}
```

Each test function has the `! { Test }` effect. Effects propagate to callers,
so production code declared without `Test` cannot call test helpers; the
checker rejects it.

## How the Surf and Deep files stay in sync

The [maintained Surf/Deep pairs](surf_and_deep.md) have `.dp` files generated
by `chelis deep`. `uv run scripts/regen_deep.py` regenerates them, and
[`tests/test_surf_deep_equivalence.py`](../tests/test_surf_deep_equivalence.py)
fails CI if a paired `.dp` differs from what `chelis deep` produces now.

## Test lanes

| Lane | What it checks | Covers |
|---|---|---|
| `chelis check src/basics/hellotensor.ch` | parse, types, dimensions, effects, linearity | the whole package |
| `chelis lint --check .` | naming and style rules from `spec/01-nomenclature.md` | every `.ch` |
| `chelis test tests/` | runtime assertions in the IR evaluator | `tests/**/*.ch` |
| `chelis test tests_neg --expect neg` | each program is rejected with its pinned diagnostic | `tests_neg/check/` |
| `pytest tests/test_negative_examples.py` | each program is rejected with its declared error kind | `tests_neg/check/` |
| `pytest tests/test_surf_deep_equivalence.py` | each `.dp` equals `chelis deep` of its `.ch` | [maintained Surf/Deep pairs](surf_and_deep.md) |
| `pytest tests/test_c_backend.py` | compile to C, link, run, compare with golden output | `verify/*.ch` |
| `pytest tests/test_octant_pairs.py` | `.tex` retranslates to the committed outputs | `octant/*.tex` |
| `pytest tests/test_c_earchin_artifacts.py` | fixtures match the release; witnesses prove; the failure maps to its EARS line | `c-earchin/finance_options/` |

## Tracing C back to source

The C that `chelis build --target c` emits carries `// span:` comments
naming the Surf source ranges it came from. The C-backend lane builds each
`verify/` program, runs it, and compares its output with
`verify/expected/<name>.txt`, so a lowering change that alters behavior
shows up as a golden mismatch.
