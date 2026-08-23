# Blocked-probe suite

One expected-to-fail reproducer per open upstream blocker
(`<area>/<name>.ch` + `<name>.expect`; line 1 = pinned diagnostic substring,
lines 2+ = the `chelis#NNN` citation + on-pass de-narrowing instructions).
Run with `chelis test tests_blocked/ --expect blocked`. Blockers the harness
cannot express (check-context-only, cross-module) are listed here for manual
re-probe.

## Manual re-probes

Both of this repo's open blockers fail outside `chelis test`: one at the
Deep-to-Surf resugaring boundary and one in the C backend. Neither produces a
runner diagnostic the `--expect blocked` harness can pin, so both are re-probed
by the commands below at every pin bump. Record the outcome in
[`../docs/UPSTREAM_BUGS.md`](../docs/UPSTREAM_BUGS.md).

### chelis#1258 — `Frame[N]` resugaring

```sh
chelis migrate surf --from 0.18 --check src/coral/framebasics.ch
```

- **Blocked (expected today):** exits non-zero with
  `Deep resugaring failed: Deep name `3` is not a valid Surf function-quantifier identifier`.
- **Fixed:** exits zero. Then drop the five-file exclusion from the migration
  batch and re-run `chelis migrate surf --from 0.18 --check` over the whole tree.

The same defect surfaces through `chelis surf` with a different message, which
is worth checking too because the two diagnostics disagree about the cause:

```sh
chelis deep src/coral/framebasics.ch > /tmp/fb.dp && chelis surf /tmp/fb.dp
```

- **Blocked (expected today):** ``error: Deep `t-var` child 0 must be a name atom``.

### chelis#405 — whole-package C build with scalar-`wrt` `grad`

```sh
chelis build --target c src/capstone/blackscholes.ch -o /tmp/grad_build
```

Run this **from the reef root**, with any in-root entry file — the entry does
not matter, because the whole package is lowered.

- **Blocked (expected today, re-confirmed on 0.18.5):** aborts with
  ``error: `chelis build --target c` can't lower these defs. Their body applies/binds `grad` (or `vmap`) in a position the host lane can't resolve``,
  naming `...BlackScholes__delta` and `...BlackScholes__vega`.
- **Fixed:** the build succeeds. Then drop the copy-to-`/tmp` step from
  `.github/workflows/nightly.yml` and `docker/Dockerfile`, and add the capstone
  Greeks to `tests/test_c_backend.py`.

Use an entry under `src/`. As of 0.18.5, naming a `verify/*.ch` file from the
reef root rejects earlier and for an unrelated reason —
`verify/grad_quadratic.ch is not a source file under any declared root ... (roots: [src])`
— which masks this probe rather than answering it.
