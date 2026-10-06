# Upstream Bugs

Chelis bugs and capability gaps that shape this corpus. Each is filed
upstream and cited by number (`chelis#NNN`, or `<shell>#NNN` for a sibling
package), both here and at every place the corpus works around it.

**Re-probe cadence.** Tracking entries are checked at each toolchain pin bump
using the named probe. Archived entries record completed checks.

## Actively blocking

(none)

## Tracking

### chelis#2552: host-runtime `grad` cannot lower a function that uses a string literal

`chelis test` fails `grad` over any function whose body passes a string
literal, even when the string only selects a branch. Every Coral column
lookup is keyed by a string name, so differentiating through a frame fails.

**Effect here:** `src/coral/adthroughdataframe.ch` builds a frame from a
tensor, but its gradient example differentiates the tensor loss directly. The
Coral README and the feature matrix say so.

**Probe:** [`../tests_blocked/coral/grad_string_key.ch`](../tests_blocked/coral/grad_string_key.ch)
under `chelis test tests_blocked --expect blocked`.
**Probe result:** The pinned diagnostic persists with Coral 0.7.45 and Chelis 0.18.13.

**De-narrow when fixed:** make the Coral example differentiate through
`get_float_col`, and describe it as gradient flow through a frame.

### chelis#2840: Reef GitHub fetches require a token even for public releases

`chelis reef install --from-github` refuses to start without `GITHUB_TOKEN`
or a signed-in `gh`, although the Coral and Nautilus releases it downloads
are public. chelis#3295 fixed this on `main` on 2026-10-06, but no release
contains the fix yet (v0.19.0 does not).

**Effect here:** the Quickstart asks for a GitHub CLI sign-in and
`GITHUB_TOKEN` (the README, [`getting_started.md`](getting_started.md), and
the Dockerfile header), and the `Quickstart build with public access only`
CI job passes `github.token`.

**Probe:** build the image without a token:
`GITHUB_TOKEN= docker compose -f docker/docker-compose.yml build`.
**Probe result:** On Chelis 0.18.13 (2026-10-06) the build stops at the Coral
install with ``GITHUB_TOKEN is not set and `gh auth token` did not yield a
token``.

**De-narrow when fixed:** make the sign-in and the `GITHUB_TOKEN` export
optional in the README and `getting_started.md`, as a way to raise GitHub's
rate limit. Keep `github.token` in the CI job, because anonymous requests
from shared runners share one rate limit.

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
builds and prints `out = 3.0`.

### chelis#406: runtime leaks under valgrind

Closed upstream. Re-probed on 0.18.11 (2026-09-25): the nightly valgrind
lane on `verify/grad_quadratic.ch` reports 0 errors and 0 bytes lost, with
only the libgomp thread-pool suppression applied.
