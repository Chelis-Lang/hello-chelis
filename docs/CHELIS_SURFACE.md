# Chelis Capability Surface (this shell)

<!-- BEGIN CHELIS MANAGED BLOCK: chelis-surface-header chelis@0.18.12 (sha256:28011bed9ccb5778) -->
This file is a domain-scoped view of the canonical Chelis capability surface,
generated for the pinned toolchain. Each capability row is marked `@pin` (usable
at the current pin) or `@upstream` (lands at the next bump). **Read it before
designing around a suspected language gap** — most downstream over-narrowing
traces to not knowing the real surface. Regenerate with `chelis reef conform
sync` at every pin bump; the upstream source of truth is `docs/CHELIS_SURFACE.md`
in `Chelis-Lang/chelis`.
<!-- END CHELIS MANAGED BLOCK: chelis-surface-header -->

## How this shell's view is scoped

The compiler version is pinned in [`reef.toml`](../reef.toml).

hello-chelis has no single library domain — it is the teaching corpus, so its
"domain" is *whatever a reader is shown*. The rows below therefore track the
capabilities the corpus **demonstrates**, and the gaps that force an example to
be written differently than a reader would expect. A capability chelis has but
this corpus does not teach is not a gap; it is a missing example, and belongs in
[`docs/curriculum.md`](curriculum.md) instead.

Language semantics come from the upstream canonical file and the numbered specs.
Do not re-derive them here.

## Capabilities exercised by the corpus

| Capability | Where | Status |
|---|---|---|
| Named tensor dimensions, dim polymorphism | `src/basics/hellotensor.ch`, `dimpoly.ch` | `@pin` |
| ADTs + `match`, modules + imports | `src/basics/pipeandmatch.ch`, `modulesandimports.ch` | `@pin` |
| Precision + explicit `cast` (no implicit promotion) | `src/basics/precisioncast.ch` | `@pin` |
| Explicit random keys; `IO` and `Test` effects | `src/basics/effectsrandom.ch`, `src/std/tensorio.ch` | `@pin` |
| Linearity: `copy`, `&borrow`, implicit auto-borrow | `src/basics/linearity.ch` | `@pin` |
| `grad`, `vmap`, `jit` + `realize`, macros | `src/basics/{vmap,jitrealize,macrobasic}.ch` | `@pin` |
| `chelis-std`: activations, norms, reductions, losses | `src/std/` | `@pin` |
| `chelis-std`: `Decimal[P, S]`, `DateTime`, `List`/`Dict`/iter | `src/std/` | `@pin` |
| `coral` typed dataframes, `group_by`, joins, reshape, CSV/JSON | `src/coral/` | `@pin` |
| AD through dataframe ops | `src/coral/adthroughdataframe.ch` | `@pin` |
| `nautilus` special functions, distributions, linalg, stats, ODE/SDE | `src/nautilus/` | `@pin` |
| `octant` LaTeX -> Deep -> Surf triples | `octant/` | `@pin` |
| `c-earchin` EARS requirements -> property witnesses | `c-earchin/` | `@pin` |
| C-backend lowering: `grad` over a tensor reduction, `relu`, `sigmoid`, `cast`, `realize` | `verify/` | `@pin` |
| Capstones: Black-Scholes Greeks, SGD linear regression, transformer block | `src/capstone/` | `@pin` |

## Gaps that shape an example

Each row is a place where the corpus is written around a limitation rather than
around the reader. Every one cites its upstream issue; see
[`UPSTREAM_BUGS.md`](UPSTREAM_BUGS.md) for the probe status.

| Gap | Effect on the corpus | Status |
|---|---|---|
| Host-lane C backend rejects a scalar-gradient callee with local bindings (chelis#2379) | `verify/` programs are built in isolation from `/tmp`; a whole-package `chelis build` aborts on the capstone Black-Scholes Greeks | `@upstream` |
| Integer type-application arguments are unenforced (chelis#1247) | `Frame[3]` is documentation, not a checked constraint; the corpus must not present it as one | `@upstream` |
| Per-test-worker dependency recompilation | the native suite is compile-bound; CI's `chelis test` budget is 900s, not the 180s the suite's runtime warrants | `@upstream` |
