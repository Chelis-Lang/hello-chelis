# Draft: `chelis test` recompiles dependencies per test worker

**Filing condition:** measure the split between compile time and test runtime
with `--jobs 1` vs `--jobs auto` on a quiet machine, and confirm the cost scales
with worker count rather than with test count. Without that split the report is
"the suite is slow", which is not actionable. File once the numbers exist.

## Observed

`chelis test tests/ --jobs auto` over hello-chelis's ~115-test tree is
compile-bound, not runtime-bound. The suite exceeded the previous 180s CI budget
as the shell dependency set grew; the budget is now 900s
(cited at the site in `.github/workflows/ci.yml`).

The suspicion is that each test worker compiles the dependency graph
independently, so wall-clock cost grows with worker count instead of amortizing
across them. That would make `--jobs auto` actively worse than `--jobs 1` past
some worker count, which is the measurement to take.

## Why it is not a hello-chelis bug

Nothing in this repo controls dependency compilation scheduling. The corpus is
correct (115/0 locally); the only local lever is the timeout, which is a
symptom-level workaround and is marked as one.

## Evidence to collect before filing

- `time chelis test tests/ --jobs 1` and `--jobs 2/4/8` on a quiet machine.
- Whether a warm compiled-dependency cache changes the shape. Note that 0.18.5
  invalidated every on-disk cache format and re-keyed cache identity on a build
  fingerprint (chelis#1156), so any pre-0.18.5 measurement is not comparable.
- Whether the effect persists with a single dependency vs the full
  `chelis-std` + `coral` + `nautilus` set.
