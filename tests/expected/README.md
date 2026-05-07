# Expected outputs

Per-example golden snapshots referenced by the test harness. Most
examples assert their invariants in-line via `Std.Test.assert_*` calls,
so this directory mostly holds:

- The deliberately-broken negative examples (e.g. a `use-after-consume`
  program) that the harness expects `chelis check` to *reject*, with the
  expected error category and suggestion text recorded here as JSON.
- A few golden eval-output snapshots for examples whose `main()` returns
  a tensor that's easier to compare via stdout than via a `Std.Test`
  assertion.
