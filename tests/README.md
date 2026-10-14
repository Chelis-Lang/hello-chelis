# `tests/`

Chelis tests live in `tests/<area>/<name>.ch`, one module per module in
`src/<area>/`. Run them with:

```sh
chelis test tests/ --jobs auto
```

The Python files here cover what `chelis test` does not:

| File | What it checks |
|---|---|
| [`test_surf_deep_equivalence.py`](test_surf_deep_equivalence.py) | each [maintained Surf/Deep pair](../docs/surf_and_deep.md) matches `chelis deep` |
| [`test_negative_examples.py`](test_negative_examples.py) | every `../tests_neg/check/*.ch` is rejected by `chelis check` with the error kind in its `-- chelis-expect-fail: <kind>` header |
| [`test_c_backend.py`](test_c_backend.py) | every `../verify/*.ch` compiles to C, links, runs, and prints its golden output |
| [`test_c_earchin_artifacts.py`](test_c_earchin_artifacts.py) | the c-earchin fixtures match their release hashes, the witnesses prove, and the failing witness is reported against its EARS line |
| [`test_literature_properties.py`](test_literature_properties.py) | quadratic AD descent and parabola bounds are proved under real arithmetic; four false claims yield SMT counterexamples |
| [`test_clarabel_calibration.py`](test_clarabel_calibration.py) | constrained option-hedge properties prove conditionally on the Clarabel ideal-optimality axiom; a reversed comparison yields an SMT counterexample |
| [`test_greek_properties.py`](test_greek_properties.py) | four imported AD Greek bounds stay source-bound, the pinned SMT lane reports them unsupported, and Beacon certifies their real-arithmetic full-box claims; two false claims have sampled and Beacon-checked counterexamples |
| [`test_book_examples.py`](test_book_examples.py) | every lesson and package example in [`../docs/book/src/`](../docs/book/src/) checks clean and prints the output the book shows; every quoted `def` is verbatim in the module it links |

Run them with:

```sh
uv run --group test pytest tests/
```

The Clarabel proof test takes several minutes. CI runs it for changes to the
example, proof, dependency pins, and owning workflows, and on a nightly
schedule. The regular PR corpus runs the other Python tests and the numerical
Clarabel runtime tests. Run the proof test directly with
`uv run --group test pytest tests/test_clarabel_calibration.py`.

A test whose tool is missing from `PATH` (`chelis` or `gcc`) is skipped, so
run them inside the Docker image for full coverage.

## Adding a test

| To add | Do this |
|---|---|
| A runtime test | add a `def test_*() -> unit ! { Test }` to `tests/<area>/<name>.ch`, then `uv run scripts/regen_deep.py` |
| A program that must be rejected | add a `.ch` under `tests_neg/check/` whose first line is `-- chelis-expect-fail: <ErrorKind>`, plus a `.expect` file whose first line is a substring of the expected diagnostic |
| A compiled-C example | add a standalone `.ch` under `verify/` and save its output as `verify/expected/<name>.txt` |

The harnesses discover new files automatically.

## Beacon Greek acceptance

The ordinary corpus tests use the pinned compiler. The explicit Beacon check
requires `CHELIS_BEACON_BIN` to name a verified engine binary:

```sh
uv run --group test python tests/test_greek_properties.py
```

The check requires the compiler to dispatch the actual exported AD graph,
with exact goals, source declarations, roots, input box, and engine digest.
The audited fingerprint fixture pins declaration, expression, graph, request,
and Beacon DAG digests for the published compiler and shell graph; source or
compiler changes require a new proof run and an explicit fixture review.
The four full-box goals require complete, strict real-arithmetic Arb covers;
the two false controls require checked Arb point witnesses. These results do
not certify rounded floating-point execution. The compiled-C endpoint tests
remain samples.
