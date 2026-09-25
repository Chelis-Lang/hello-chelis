# Chelis Capability Surface (this shell)

<!-- BEGIN CHELIS MANAGED BLOCK: chelis-surface-header chelis@0.18.11 (sha256:28011bed9ccb5778) -->
This file is a domain-scoped view of the canonical Chelis capability surface,
generated for the pinned toolchain. Each capability row is marked `@pin` (usable
at the current pin) or `@upstream` (lands at the next bump). **Read it before
designing around a suspected language gap** — most downstream over-narrowing
traces to not knowing the real surface. Regenerate with `chelis reef conform
sync` at every pin bump; the upstream source of truth is `docs/CHELIS_SURFACE.md`
in `Chelis-Lang/chelis`.
<!-- END CHELIS MANAGED BLOCK: chelis-surface-header -->

## How this shell's view is scoped

hello-chelis has no single library domain: it is the teaching corpus, so the
rows below track the capabilities the corpus **demonstrates**, plus the gaps
that force an example to be written differently than a reader would expect. A
capability Chelis has but this corpus does not teach is a missing example, not
a gap; add it to [`curriculum.md`](curriculum.md).

Language semantics come from the upstream canonical file and the numbered
specs. Do not re-derive them here.

## Capabilities exercised by the corpus

| Capability | Where | Status |
|---|---|---|
| Named tensor dimensions, dimension polymorphism | `src/basics/hellotensor.ch`, `dimpoly.ch` | `@pin` |
| ADTs and `match`, modules and imports | `src/basics/pipeandmatch.ch`, `modulesandimports/` | `@pin` |
| Precision and explicit `cast` (no implicit promotion) | `src/basics/precisioncast.ch` | `@pin` |
| Effects (`Random`, `IO`, `Test`) and the `with seed` handler, evaluated in the host runtime | `src/basics/effectsrandom.ch`, `src/std/tensorio.ch` | `@pin` |
| Linearity: consumption and `&` borrows | `src/basics/linearity.ch` | `@pin` |
| `grad`, `vmap`, `realize`, macros, evaluated in the host runtime | `src/basics/{gradbasic,vmap,jitrealize,macrobasic}.ch` | `@pin` |
| Checked extents on dimension-parameterized ADTs (`Frame[3]`) | `tests_neg/check/adt_extent_mismatch.ch` | `@pin` |
| `chelis-std` and `school`: activations, norms, reductions, losses | `src/std/` | `@pin` |
| `chelis-std`: `Decimal`, dates, `List` / `Dict` / iteration, text I/O | `src/std/` | `@pin` |
| `coral` typed dataframes, `group_by`, joins, windows, reshape, CSV | `src/coral/` | `@pin` |
| `nautilus` special functions, distributions, linear algebra, statistics, ODE/SDE | `src/nautilus/` | `@pin` |
| `octant` LaTeX -> Deep -> Surf triples | `octant/` | `@pin` |
| `c-earchin` EARS requirements -> property witnesses, proven by `chelis prove` | `c-earchin/` | `@pin` |
| C-backend lowering: `grad` over a tensor reduction, `relu`, `sigmoid`, `cast`, `realize` | `verify/` | `@pin` |
| Capstones: Black-Scholes Greeks (host runtime), SGD linear regression, transformer block | `src/capstone/` | `@pin` |

## Gaps that shape an example

Each row is a place where the corpus is written around a limitation rather
than around the reader. Each cites its upstream issue; see
[`UPSTREAM_BUGS.md`](UPSTREAM_BUGS.md) for probe status.

| Gap | Effect on the corpus | Status |
|---|---|---|
| C-backend scalar `grad` rejects some differentiated functions; the Black-Scholes Greeks trip it (chelis#2379) | `verify/` programs are built standalone from `/tmp`; a whole-package `chelis build` fails on the capstone Greeks, which are tested in the host runtime instead | `@upstream` |
| Host-runtime `grad` cannot lower a function that uses a string literal (chelis#2552) | differentiating through a Coral frame (string-keyed column lookup) is not demonstrated; the Coral gradient example differentiates the tensor directly | `@upstream` |
| `chelis test` default batch mode is about 2x slower than `--batch-mode file` (chelis#1391) | CI and the docs pass `--batch-mode file` | `@upstream` |
