# `tests/` — both Chelis-native and Python harnesses

The repo's primary test surface is **Chelis-native**: every test
function under `tests/<area>/<name>.ch` is a
`def test_*() -> unit ! { Test }` whose `Std.Test.assert_*` calls
verify behavior. Run them all with:

```sh
chelis test tests/
```

Python under `tests/` covers the lanes the native runner doesn't
reach:

| File | Lane | What it asserts |
|---|---|---|
| [`test_surf_deep_equivalence.py`](test_surf_deep_equivalence.py) | drift | every committed `.dp` is byte-identical to `chelis deep <ch>` |
| [`test_negative_examples.py`](test_negative_examples.py) | reject | every `negative/*.ch` is rejected by `chelis check` with the kind declared in its `-- chelis-expect-fail: <kind>` header |
| [`test_octant_pairs.py`](test_octant_pairs.py) | round-trip | every `octant/*.tex` re-translates to the committed `.dp`/`.spans.json`/`.ch` byte-equally |
| [`test_c_backend.py`](test_c_backend.py) | full lowering | every `verify/*.ch` builds via `chelis build --target c`, links, runs, and prints output matching `verify/expected/<name>.txt` |

Run them all:

```sh
python3 -m pytest tests/
```

## Adding test cases

| To add | Drop |
|---|---|
| A Chelis-native runtime test | a new `def test_*() -> unit ! { Test }` in `tests/<area>/<name>.ch`, then run `chelis test` |
| A program that must be rejected | a `.ch` under `tests/negative/` with `-- chelis-expect-fail: <ErrorKind>` as the first content line |
| A LaTeX → Deep test | a `.tex` under `octant/`, then `python3 scripts/regen_octant.py` to capture the triple |
| A C-backend full-lowering test | a `.ch` under `verify/` with a top-level expression, capture stdout into `verify/expected/<name>.txt` |

Each new addition is picked up automatically by the existing
parametrized harnesses. No registry to update.
