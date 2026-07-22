# Blocked-probe suite

One expected-to-fail reproducer per open upstream blocker
(`<area>/<name>.ch` + `<name>.expect`; line 1 = pinned diagnostic substring,
lines 2+ = an upstream tracker, source, or `docs/issue_drafts/` citation plus
on-pass de-narrowing instructions).
Run with `chelis test tests_blocked/ --expect blocked`. Blockers the harness
cannot express (check-context-only, cross-module, or C-backend-only) are listed
here for manual re-probe.

| Probe | Source | Promotion condition |
|---|---|---|
| `capstone/blackscholes_grad.ch` | `docs/issue_drafts/blackscholes_grad_bool_condition.md` | native delta and vega exact-value assertions pass |
| `coral/parquet.ch` | `Chelis-Lang/coral@v0.7.31:src/io.ch:203` | released Coral Parquet round-trip passes |

## Manual C-backend blocker

`chelis#716` remains visible only after C compilation and execution: an f32 to
bf16 tensor cast checks and evaluates, but the C host-boundary printer reads the
2-byte bf16 buffer as f32. Re-probe with the `R11` procedure recorded in
`openspec/changes/archive/2026-07-22-bump-chelis-0-16-1-conformance/evidence/reprobe-inventory.md`.
