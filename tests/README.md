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

Run them with:

```sh
uv run --group test pytest tests/
```

A test whose tool is missing from `PATH` (`chelis` or `gcc`) is skipped, so
run them inside the Docker image for full coverage.

## Adding a test

| To add | Do this |
|---|---|
| A runtime test | add a `def test_*() -> unit ! { Test }` to `tests/<area>/<name>.ch`, then `uv run scripts/regen_deep.py` |
| A program that must be rejected | add a `.ch` under `tests_neg/check/` whose first line is `-- chelis-expect-fail: <ErrorKind>`, plus a `.expect` file whose first line is a substring of the expected diagnostic |
| A compiled-C example | add a standalone `.ch` under `verify/` and save its output as `verify/expected/<name>.txt` |

The harnesses discover new files automatically.
