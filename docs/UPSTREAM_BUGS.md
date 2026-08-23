# Upstream Bugs

Track suspected chelis bugs and capability gaps here. File upstream and cite by
`chelis#NNN` (never a prose name). Re-probe at every pin bump.

Every workaround in this repo cites its issue **at the site**. If you find a
narrowing with no citation, that is the defect — either find the issue or file
one.

Probe commands live in [`../tests_blocked/README.md`](../tests_blocked/README.md).

## Actively blocking

### chelis#1258 — `Frame[N]` breaks `chelis surf` and `chelis migrate surf`

A concrete dimension argument on a parameterized ADT desugars to `(t-var {} N)`,
a `t-var` whose child is an integer rather than a name. The typed Deep-to-Surf
resugaring boundary correctly refuses it, so both `chelis surf` and
`chelis migrate surf` fail on any file that mentions such a type — even though
`chelis fmt --check`, `chelis check`, `chelis deep`, and `chelis test` all
accept the same file.

**Bites** `src/coral/{framebasics,groupbyagg,io,joins,reshape}.ch`, which use
Coral's `Frame[N]`.

**Workaround:** those five files are excluded from `chelis migrate surf
--inplace` batches and their rewrites are hand-applied. `migrate --inplace` is a
whole-batch transaction, so leaving them in aborts the migration of every other
file too.

**Filed** 2026-08-22 during the 0.18.5 bump, with a self-contained reproducer.
Parented to chelis#1024; the same desugar arm is named from the checker side by
chelis#1247.

**De-narrow when fixed:** drop the exclusion and migrate the whole tree in one
batch.

### chelis#405 — host-lane C backend cannot lower scalar-`wrt` `grad`

`chelis build --target c` cannot lower `grad(f)(x)` differentiating w.r.t. a
scalar f32, which the capstone Black-Scholes `delta`/`vega` use. A whole-package
build therefore aborts regardless of the entry file. Re-confirmed on 0.18.5.

**Workaround:** `verify/*.ch` are copied to `/tmp` and built in isolation so the
build lowers only that file. Cited at the site in
[`.github/workflows/nightly.yml`](../.github/workflows/nightly.yml) and
[`docker/Dockerfile`](../docker/Dockerfile).

**De-narrow when fixed:** build `verify/` in place and add the capstone Greeks
to the C-backend lane.

## Tracking

### chelis#1247 — integer type-application arguments are unenforced

`Frame[3]` constrains nothing: the declared extent is never checked against the
value, and on a type parameter the integer is a wildcard that unifies with
anything. The corpus uses `Frame[N]` throughout `src/coral/`.

**Effect here:** documentation-only. The corpus must not present `Frame[3]` as a
checked constraint until this lands.

**De-narrow when fixed:** add a negative example under `tests_neg/check/`
asserting that a `Frame[3]` holding two rows is rejected.

### `docs/issue_drafts/per_worker_dep_recompilation.md` — native suite is compile-bound

The native test runner recompiles dependencies per test worker, which makes the
~105-test tree compile-bound rather than runtime-bound. CI's `chelis test` step
carries a 900s budget rather than the ~180s the tests themselves warrant. Cited
at the site in [`.github/workflows/ci.yml`](../.github/workflows/ci.yml).

**Not yet filed** — see
[the draft](issue_drafts/per_worker_dep_recompilation.md) for the filing condition.

## Parked

(none yet)

## Archived

### chelis#406 — runtime leaks under valgrind

Closed upstream COMPLETED on 2026-06-19. The two suppressions this repo carried
for it were removed during the 0.18.5 bump, after the staleness audit found they
had survived two pin bumps past the fix. Both frames are reachable in the
nightly's `grad_quadratic` program, so the next nightly is the real re-probe. A
red nightly there means a live residual: file a new issue and cite it, never
re-add a suppression for a closed one.

### Manual layer-norm false positive

Resolved upstream. Record retained at
[`upstream_resolved/manual_layer_norm_false_positive.md`](upstream_resolved/manual_layer_norm_false_positive.md).
