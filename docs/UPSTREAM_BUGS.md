# Upstream Bugs

Chelis bugs and capability gaps that shape this corpus. Each is filed
upstream and cited by number (`chelis#NNN`, or `<shell>#NNN` for a sibling
package), both here and at every place the corpus works around it.

**Re-probe cadence.** Every entry in *Actively blocking* and *Tracking* is
re-probed at each toolchain pin bump, per surface, using its probe below.
*Parked* entries are re-probed when their stated trigger fires. *Archived*
entries are not re-probed; each records the verdict that archived it.
Commands for the manual probes live in
[`../tests_blocked/README.md`](../tests_blocked/README.md).

## Actively blocking

### chelis#2379: C-backend scalar `grad` rejects some differentiated functions

`chelis build --target c` rejects `grad(f, wrt=s)(...)` for some scalar
functions `f` with "can't lower these defs ... applies/binds `grad` (or
`vmap`) in a position the host lane can't resolve". Building from the package
root lowers the whole package, and the capstone
`Hello.Capstone.BlackScholes.delta` / `vega` trip it, so a whole-package C
build fails regardless of the entry file.

**Re-probe (0.18.12, 2026-10-01):** still blocked in the isolated package
containing this checkout's basics, std, Nautilus, and Black-Scholes sources.
The build rejects `BlackScholes__delta` and `BlackScholes__vega` with the
same host-lane `grad` diagnostic.

**Earlier re-probe (0.18.11, 2026-09-25):** still blocked. The issue attributes the
failure to local bindings, but on 0.18.11 the rejection follows a
`cast(<literal>, f32)` constant inside the differentiated function instead:
local bindings without a cast build, and the issue's own direct-expression
control (which contains `cast(1.0, f32)`) is rejected. Probe table posted on
the issue. The Greeks run and are tested in the host runtime
(`tests/capstone/blackscholes.ch`).

**Workaround:** `verify/*.ch` are copied to `/tmp` and built alone. Cited at
the site in [`.github/workflows/nightly.yml`](../.github/workflows/nightly.yml)
and [`docker/Dockerfile`](../docker/Dockerfile).

**De-narrow when fixed:** build the capstone Greeks through the C backend and
add them to `tests/test_c_backend.py`.

## Tracking

### chelis#2778: exact `Std.Decimal` arithmetic is unavailable

Chelis 0.18.12 checks `src/std/decimal.ch` but rejects all four runtime
assertions with `Std.Decimal is unavailable`. The assertions are preserved in
[`../tests_blocked/std/decimal.ch`](../tests_blocked/std/decimal.ch), with the
diagnostic pinned in its `.expect` sidecar. Re-probe with
`chelis test tests_blocked/std --expect blocked`. Restore the suite to
`tests/std/` when exact arithmetic is implemented.

### chelis#2779: exact `Std.Time` arithmetic is unavailable

Chelis 0.18.12 checks `src/std/datetimecal.ch` but rejects all three runtime
assertions with `Std.Time is unavailable`. The assertions are preserved in
[`../tests_blocked/std/datetimecal.ch`](../tests_blocked/std/datetimecal.ch),
with the diagnostic pinned in its `.expect` sidecar. Re-probe with
`chelis test tests_blocked/std --expect blocked`. Restore the suite to
`tests/std/` when exact Gregorian and duration arithmetic is implemented.

### chelis#2552: host-runtime `grad` cannot lower a function that uses a string literal

`chelis test` fails `grad` over any function whose body passes a string
literal, even when the string only selects a branch. Every Coral column
lookup is keyed by a string name, so differentiating through a frame fails.

**Effect here:** `src/coral/adthroughdataframe.ch` builds a frame from a
tensor, but its gradient example differentiates the tensor loss directly. The
Coral README and the feature matrix say so.

**Probe:** [`../tests_blocked/coral/grad_string_key.ch`](../tests_blocked/coral/grad_string_key.ch)
under `chelis test tests_blocked --expect blocked`. Re-probe: fails with the
pinned diagnostic on 0.18.11 (2026-09-30). The 0.18.12 re-probe awaits a
compiler-matching Coral release.

**De-narrow when fixed:** make the Coral example differentiate through
`get_float_col`, and describe it as gradient flow through a frame.

### chelis#1391: `chelis test --batch-mode auto` is slower than `--batch-mode file`

On a 10-core machine, the 113-test corpus measured on 2026-09-25 took
68s with `--jobs auto` and
the default batch mode, 32s with `--batch-mode file`, and 67s with
`--jobs 1` (0.18.11, 2026-09-25). On the 4-vCPU GitHub runner the two
modes are equivalent for the same 113 tests: 203s with the default and 205s
with `--batch-mode file`.

**Workaround:** none in CI, which keeps the default. The docs mention
`--batch-mode file` as a local speed-up.

**De-narrow when fixed:** drop the `--batch-mode file` tip from
`docs/getting_started.md` and `tests/README.md`.

The full 0.18.12 timing re-probe awaits a compiler-matching Coral release.

## Parked

(none yet)

## Archived

### chelis#1247: integer type-application arguments are unenforced

Closed upstream. Re-probed on 0.18.11 (2026-09-25): a `Column[3]` built from
a two-element tensor is rejected with `DimensionMismatch`. Pinned by
[`tests_neg/check/adt_extent_mismatch.ch`](../tests_neg/check/adt_extent_mismatch.ch).

### chelis#1258: `Frame[N]` Deep resugaring

Closed upstream. Re-probed on 0.18.11 (2026-09-25): `chelis migrate surf
--from 0.18 --check` passes on all 92 maintained `.ch` files, and
`chelis deep` then `chelis surf` succeeds on every `src/coral/` file.

### chelis#405: scalar-`wrt` `grad` in the C backend

Closed upstream. Re-probed on 0.18.11 (2026-09-25): the issue's reproducer
builds and prints `out = 3.0`. The remaining C-backend `grad` rejection is
chelis#2379.

### chelis#406: runtime leaks under valgrind

Closed upstream. Re-probed on 0.18.11 (2026-09-25): the nightly valgrind
lane on `verify/grad_quadratic.ch` reports 0 errors and 0 bytes lost, with
only the libgomp thread-pool suppression applied.
