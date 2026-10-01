# Blocked-probe suite

One expected-to-fail reproducer per open upstream blocker
(`<area>/<name>.ch` + `<name>.expect`; line 1 = pinned diagnostic substring,
lines 2+ = the `chelis#NNN` citation + on-pass de-narrowing instructions).
Run with `chelis test tests_blocked/ --expect blocked`. Blockers the harness
cannot express (check-context-only, cross-module, package-build-context) are
listed here for manual re-probe.

[`coral/grad_string_key.ch`](coral/grad_string_key.ch) pins chelis#2552: the
host runtime cannot evaluate `grad` through a string-keyed Coral column
lookup. Its [sidecar](coral/grad_string_key.expect) names the diagnostic and
the de-narrowing steps. Two more probes retain the former runtime assertion suites for exact
[`Std.Decimal`](std/decimal.ch) and [`Std.Time`](std/datetimecal.ch). They
pin the 0.18.12 unavailability diagnostics from chelis#2778 and chelis#2779;
their sidecars name the steps to restore the tests when implemented.
The other open blocker, chelis#2379, fails only under
`chelis build --target c`, which the `chelis test` runner cannot express.

## Manual re-probes

Run these at every pin bump and record the outcome in
[`../docs/UPSTREAM_BUGS.md`](../docs/UPSTREAM_BUGS.md).

### chelis#2379: whole-package C build with scalar `grad`

```sh
chelis build --target c src/capstone/blackscholes.ch -o /tmp/grad_build
```

Run this **from the reef root** with any entry under `src/`. The entry does
not matter, because the whole package is lowered. (Naming a `verify/*.ch`
file from the reef root fails earlier, for an unrelated reason: `verify/` is
not a declared source root.)

- **Blocked (re-confirmed on 0.18.11):** aborts with
  ``error: `chelis build --target c` can't lower these defs. Their body applies/binds `grad` (or `vmap`) in a position the host lane can't resolve``,
  naming `...BlackScholes__delta` and `...BlackScholes__vega`.
- **Fixed:** the build succeeds. Then drop the copy-to-`/tmp` step from
  `.github/workflows/nightly.yml` and `docker/Dockerfile`, and add the
  capstone Greeks to `tests/test_c_backend.py`.

On 0.18.11 the rejection follows a `cast(<literal>, f32)` constant inside the
differentiated function rather than the local bindings the issue names; see
the probe table on the issue. A standalone check of that narrower shape:

```sh
printf 'module V\ndef f(s: f32, k: f32) -> f32 = add(s, cast(1.0, f32))\ndef df(s: f32, k: f32) -> f32 = grad(f, wrt=s)(s, k)\nout = df(cast(2.0, f32), cast(3.0, f32))\n' > /tmp/v.ch
chelis build --target c /tmp/v.ch -o /tmp/v
```
