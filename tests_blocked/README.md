# Blocked-probe suite

One expected-to-fail reproducer per open upstream blocker
(`<area>/<name>.ch` + `<name>.expect`; line 1 = pinned diagnostic substring,
lines 2+ = the `chelis#NNN` citation + on-pass de-narrowing instructions).
Run with `chelis test tests_blocked/ --expect blocked`. Blockers the harness
cannot express (check-context-only, cross-module) are listed here for manual
re-probe.

## Manual re-probes

This repo's open blocker fails in the C backend, outside `chelis test`, so the
runner cannot pin its diagnostic. Re-probe it with the command below at every
pin bump. Record the outcome in
[`../docs/UPSTREAM_BUGS.md`](../docs/UPSTREAM_BUGS.md).

### chelis#2379 — whole-package C build with local-binding scalar `grad`

```sh
chelis build --target c src/capstone/blackscholes.ch -o /tmp/grad_build
```

Run this **from the reef root**, with any in-root entry file — the entry does
not matter, because the whole package is lowered.

- **Blocked (expected today, re-confirmed on 0.18.11):** aborts with
  ``error: `chelis build --target c` can't lower these defs. Their body applies/binds `grad` (or `vmap`) in a position the host lane can't resolve``,
  naming `...BlackScholes__delta` and `...BlackScholes__vega`.
- **Fixed:** the build succeeds. Then drop the copy-to-`/tmp` step from
  `.github/workflows/nightly.yml` and `docker/Dockerfile`, and add the capstone
  Greeks to `tests/test_c_backend.py`.

Use an entry under `src/`. As of 0.18.11, naming a `verify/*.ch` file from the
reef root rejects earlier and for an unrelated reason —
`verify/grad_quadratic.ch is not a source file under any declared root ... (roots: [src])`
— which masks this probe rather than answering it.
