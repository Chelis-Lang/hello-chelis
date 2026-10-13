# Upstream Bugs

Chelis bugs and capability gaps that shape this corpus. Each is filed
upstream and cited by number (`chelis#NNN`, or `<shell>#NNN` for a sibling
package), both here and at every place the corpus works around it.

**Re-probe cadence.** Tracking entries are checked at each toolchain pin bump
using the named probe. Archived entries record completed checks.

## Actively blocking

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
Re-probed with Chelis 0.19.4 and published Coral 0.7.50, Nautilus 0.7.55,
Shoals 0.24.20, and Shoreleave 0.1.4: the same frame-gradient remains blocked with
`application of append has no numeric IR lowering; preserve its host
execution`. The probe still exercises the string-keyed Coral column path; the
failure occurs while lowering frame construction, before the earlier
string-literal diagnostic.
**De-narrow when fixed:** make the Coral example differentiate through
`get_float_col`, and describe it as gradient flow through a frame.

## Archived

### chelis#1393: Reef auto-fetch misreads lockfile GitHub origins

Closed upstream; the `github://` lockfile origin now reaches Reef's release
installer through automatic fetch. Re-probed with Chelis 0.19.2 and a fresh
empty Reef home, with `GITHUB_TOKEN` and `GH_TOKEN` unset:
`chelis check src/basics/hellotensor.ch` fetched Shoals 0.24.19, Shoreleave
0.1.3, Nautilus 0.7.53, and Coral 0.7.49 from their canonical `github://`
origins, then
returned a perfect check (score 1, no unresolved names or errors).

The hello-chelis source book now directs readers to clone the repository and
lets Reef fetch locked dependencies on the first project check; it no longer
requires a separate install step. `mdbook build docs/book` renders the updated
source book.

### chelis#2840: public release downloads

The pinned Chelis toolchain installs public Reef packages without a GitHub
token. `GITHUB_TOKEN` remains available to raise the API rate limit. Re-probed
Chelis 0.19.2 with a fresh `CHELIS_HOME` and both `GITHUB_TOKEN` and `GH_TOKEN`
unset: `chelisup install 0.19.2` installed the Darwin arm64 toolchain, then
`chelisup show` reported only 0.19.2 in that isolated store. A separate empty
Reef home fetched every locked package from public GitHub release origins.

### chelis#1247: integer type-application arguments are unenforced

Closed upstream. Re-probed with Chelis 0.19.2 and the published dependency
graph: a `Column[3]` built from a two-element tensor is rejected with
`DimensionMismatch` (`expected () -> Column 3`, `got () -> Column 2`). Pinned by
[`tests_neg/check/adt_extent_mismatch.ch`](../tests_neg/check/adt_extent_mismatch.ch)
and passing in the negative suite.

### chelis#1258: `Frame[N]` Deep resugaring

Closed upstream. Re-probed with Chelis 0.19.2: `chelis migrate surf --from
0.18 --check` passes on all 103 `.ch` files, and the full Surf/Deep
equivalence suite passes (103 tests).

### chelis#405: scalar-`wrt` `grad` in the C backend

Closed upstream. Re-probed with Chelis 0.19.2 and the published dependency
graph: the Black-Scholes package, including scalar-wrt `delta` and `vega`,
builds to C; its C API test passes for the documented at-the-money inputs.

### chelis#406: runtime leaks under valgrind

Closed upstream. Re-probed with Chelis 0.19.2, GCC 13, and Valgrind 3.22 on
`verify/grad_quadratic.ch`: there are no definitely or indirectly lost bytes.
Valgrind reports 2,880 possibly lost bytes in 9 blocks from libgomp's thread
pool TLS; with `--errors-for-leak-kinds=definite,indirect --error-exitcode=1`,
the run exits successfully with 0 errors.
