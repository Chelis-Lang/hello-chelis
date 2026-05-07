# Python test harness

**Chelis has its own native test runner.** Every `.ch` example in this
repo declares its assertions via `Std.Test.assert_*` inside `def test_*()
-> unit ! { Test }` functions, and `chelis test examples/` is the
primary gate in CI.

This `tests/` directory holds **fallback orchestration only** — the few
things `chelis test` doesn't cover:

| File | Why Python |
|---|---|
| `test_negative_examples.py` | Snippets that must be *rejected* by `chelis check`. The native runner only knows about programs that compile. |
| `test_octant_pairs.py` | Re-runs `octant translate` on each `.tex` and asserts byte-equality with the committed `.ch`. Octant is an external CLI, not part of `chelis test`. |
| `test_chelis_build.py` | Builds a representative subset via `chelis build --target c` and greps the emitted C for `// span:` audit-chain markers. |
| `test_round_trip.py` | Surf → Deep → Surf identity, exercised by the nightly only. |

If a check could be expressed as a `Std.Test.test_*` in a `.ch` file
instead, **prefer that** and delete the Python equivalent.

## Running locally

```sh
# Primary gate — Chelis-native:
docker compose -f docker/docker-compose.yml run --rm hello-chelis \
    chelis test examples/

# Fallback orchestration:
docker compose -f docker/docker-compose.yml run --rm hello-chelis \
    python3 -m pytest tests/
```
