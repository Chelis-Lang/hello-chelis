# Python harness

Chelis-native testing is the primary surface — every example declares
its assertions via `Std.Test.assert_*` inside `def test_*() -> unit !
{ Test }` functions, run by `chelis test examples/`.

This directory holds Python only for the cases where shelling out to a
non-Chelis tool is unavoidable:

| File | Why |
|---|---|
| `negative/*.ch` + `test_negative_examples.py` | Programs that must be *rejected*. Each negative `.ch` declares its expected error kind in a `// chelis-expect-fail: <kind>` header. The harness runs `chelis check --json` and asserts the first error's kind matches. |
| `test_octant_pairs.py` | `octant` is an external binary; we re-run `octant translate` and byte-compare against the committed `.ch`. |
| `test_chelis_build.py` | `chelis build --target c` on a small subset; greps emitted C for `// span:` markers (audit-chain invariant). |

Adding a negative example: drop a new `.ch` under `negative/` whose first
line is `// chelis-expect-fail: <ErrorKind>`. The pytest parametrization
picks it up automatically.
