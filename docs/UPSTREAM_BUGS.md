# Upstream Bugs

Track suspected chelis bugs and capability gaps here. File upstream and cite by
`chelis#NNN` (never a prose name). Re-probe at every pin bump.

Every workaround in this repo cites its issue **at the site**. If you find a
narrowing with no citation, that is the defect — either find the issue or file
one.

Probe commands live in [`../tests_blocked/README.md`](../tests_blocked/README.md).

## Actively blocking

### chelis#2379 — C scalar `grad` rejects a callee with local bindings

`chelis build --target c` supports the direct-expression scalar-gradient case
that closed chelis#405, but still rejects an equivalent differentiated function
when ordinary local bindings name intermediate values. The capstone
Black-Scholes `call_price` uses such bindings, so its `delta`/`vega` still make a
whole-package build abort regardless of the entry file. Re-confirmed on 0.18.11
with both the package build and a minimized local-binding reproducer; the
equivalent direct-expression control builds.

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

### chelis#1258 — `Frame[N]` Deep resugaring

Closed upstream and verified fixed on Chelis 0.18.11. Both `chelis migrate surf
--from 0.18 --check src/coral/framebasics.ch` and the independent `chelis deep`
then `chelis surf` route pass. The complete 93-file migration check also passes,
so the old five-file manual exclusion is retired.

### chelis#405 — scalar-`wrt` `grad` in the C backend

Closed upstream and its verbatim direct-expression reproducer now builds on
Chelis 0.18.11. The hello-chelis whole-package failure had a narrower residual:
local bindings inside the differentiated scalar function, now filed as
chelis#2379.

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
