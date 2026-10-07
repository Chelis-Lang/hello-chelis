# Upstream Bugs

Chelis bugs and capability gaps that shape this corpus. Each is filed
upstream and cited by number (`chelis#NNN`, or `<shell>#NNN` for a sibling
package), both here and at every place the corpus works around it.

**Re-probe cadence.** Tracking entries are checked at each toolchain pin bump
using the named probe. Archived entries record completed checks.

## Actively blocking

## Tracking

### chelis#1393: Reef auto-fetch misreads lockfile GitHub origins

With an empty Reef registry, `chelis check` or `chelis test` can pass a full
`github://` lockfile origin to the GitHub release installer, which expects an
`org/repo@tag` coordinate. The resulting fetch fails before the package check.

**Effect here:** the no-Docker path in the book
([Set up the package](book/src/capstones.md#set-up-the-package))
explicitly runs
`chelis reef install --from-lockfile` before checking examples.

**Probe:** set `CHELIS_REEF_HOME` to a fresh directory and run
`chelis check src/basics/hellotensor.ch`; compare it with
`chelis reef install --from-lockfile` followed by the same check.
**De-narrow when fixed:** once the pinned compiler's auto-fetch handles the
lockfile origin, drop the explicit install step from the chelis.ch
hello-chelis capstones page and re-render the book from it (see the Book
section of `AGENTS.md`).

### chelis#2552: host-runtime `grad` cannot lower a function that uses a string literal

`chelis test` fails `grad` over any function whose body passes a string
literal, even when the string only selects a branch. Every Coral column
lookup is keyed by a string name, so differentiating through a frame fails.

**Effect here:** `src/coral/adthroughdataframe.ch` builds a frame from a
tensor, but its gradient example differentiates the tensor loss directly. The
Coral README and the feature matrix say so.

**Probe:** [`../tests_blocked/coral/grad_string_key.ch`](../tests_blocked/coral/grad_string_key.ch)
under `chelis test tests_blocked --expect blocked`.
**De-narrow when fixed:** make the Coral example differentiate through
`get_float_col`, and describe it as gradient flow through a frame.

## Archived

### chelis#2840: public release downloads

The pinned Chelis toolchain installs public Reef packages without a GitHub
token. `GITHUB_TOKEN` remains available to raise the API rate limit.

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
builds and prints `out = 3.0`.

### chelis#406: runtime leaks under valgrind

Closed upstream. Re-probed on 0.18.11 (2026-09-25): the nightly valgrind
lane on `verify/grad_quadratic.ch` reports 0 errors and 0 bytes lost, with
only the libgomp thread-pool suppression applied.
