# Curriculum: learning Chelis from this repo

A reading path through the corpus for someone who knows a typed functional
language (OCaml, Haskell, Rust) and a tensor framework (PyTorch, JAX) but
has never seen Chelis. Each step names the files to open and what they
teach. To get the corpus running first, see
[`getting_started.md`](getting_started.md).

## 0. Mental model (5 min)

Read [`surf_and_deep.md`](surf_and_deep.md). Chelis has two syntaxes over
one AST: Surf for people and Deep for tools. The paired examples show
what a Surf construct means.

## 1. Three ways to run a program (10 min)

Read the pipeline section of [`architecture.md`](architecture.md).
`chelis check` (type checking), `chelis test` (the in-process evaluator),
and `chelis build --target c` (compiled C) share a front end but differ
after it. Each example here is exercised by whichever of them applies.

## 2. Language fundamentals (60 min)

Walk [`src/basics/`](../src/basics/) in order. Each file is small and
self-contained, and each has a test under `tests/basics/` with the same name:

1. [`hellotensor.ch`](../src/basics/hellotensor.ch): tensors carry their
   dimensions in the type, and there is no implicit broadcasting. Compare
   with the sibling `.dp` to see how `tensor[n, f32]` desugars.
2. [`pipeandmatch.ch`](../src/basics/pipeandmatch.ch): an ADT, an
   exhaustive `match`, and the `|>` pipe.
3. [`modulesandimports/`](../src/basics/modulesandimports/): selective
   (`import M (a, b)`) and glob (`import M (..)`) imports across files.
4. [`dimpoly.ch`](../src/basics/dimpoly.ch): functions polymorphic over
   dimensions, declared with `[a, b]` binders.
5. [`precisioncast.ch`](../src/basics/precisioncast.ch): no implicit
   precision promotion; `cast` is explicit.
6. [`effectsrandom.ch`](../src/basics/effectsrandom.ch): explicit random keys,
   deterministic replay, and independent draws with `split_key`.
7. [`linearity.ch`](../src/basics/linearity.ch): tensor values are owned by
   default; a `&tensor` parameter permits repeated read-only use, and
   `copy` supplies an owner for a call that needs one. The
   [rejected call](../tests_neg/check/borrow_requires_copy.ch) shows that
   Chelis does not insert this copy for a borrowed argument.
8. [`gradbasic.ch`](../src/basics/gradbasic.ch): `grad(f, wrt=w)`
   reverse-mode differentiation of a scalar loss.
9. [`vmap.ch`](../src/basics/vmap.ch): lifting a per-example function over
   a batch dimension.
10. [`jitrealize.ch`](../src/basics/jitrealize.ch): forced evaluation
    with `realize`, next to an eager baseline.
11. [`macrobasic.ch`](../src/basics/macrobasic.ch): a macro expanding to
    typed Deep at compile time.

The desugaring rules behind each `.dp` are in
[`spec/02-surf-syntax.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/02-surf-syntax.md).

## 3. The standard library (30 min)

[`src/std/`](../src/std/) tours `chelis-std` and language builtins:
elementwise math, normalization, axis reductions, decimal arithmetic,
dates and times, collections and iteration, and effect-typed file I/O.
The catalog is in
[`src/std/README.md`](../src/std/README.md). Read the executable examples next
to their tests in [`tests/std/`](../tests/std/).

## 4. The packages (90 min; pick what fits your work)

### Coral: typed dataframes

[`src/coral/`](../src/coral/) covers the pandas-like surface: typed columns,
`group_by`, joins, rolling windows, reshape, and CSV/JSON. Numeric columns
are tensors. See [`src/coral/README.md`](../src/coral/README.md), including
its note on differentiating through frames.

### Nautilus: numerical methods

[`src/nautilus/`](../src/nautilus/) is the scipy-like surface in 14 small
modules: special functions, distributions, linear algebra, ODE/SDE solvers,
optimization, hypothesis tests, curve fitting, information theory. Nautilus is written in
Chelis, so its methods are ordinary Chelis functions.

### c-earchin: requirements to proofs

[`c-earchin/`](../c-earchin/) holds a set of finance requirements written in
EARS and the property witnesses generated from them. `chelis prove` checks
them, and a deliberately broken variant shows a failure reported against the
original requirement's line. See [`c-earchin/README.md`](../c-earchin/README.md).

## 5. Capstones (45 min)

[`src/capstone/`](../src/capstone/) combines the pieces:

- [`blackscholes.ch`](../src/capstone/blackscholes.ch): the Black-Scholes
  call price and its Greeks (delta, vega) via `grad`.
- [`linreg.ch`](../src/capstone/linreg.ch): linear regression with
  prediction, MSE loss, and an SGD step.
- [`returnsrisk.ch`](../src/capstone/returnsrisk.ch): prices, returns,
  a Coral frame grouped by ticker, and Nautilus risk statistics.

## 6. Compiling to C (20 min)

[`verify/`](../verify/) holds standalone programs that compile to C, link
against the Chelis runtime, and run. Read [`verify/README.md`](../verify/README.md),
then:

```sh
uv run --group test pytest -q tests/test_c_backend.py
```

## Upstream references

- [`spec/02-surf-syntax.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/02-surf-syntax.md):
  the Surf grammar and its desugaring to Deep.
- [`packages/chelis-std/SKILL.md`](https://github.com/Chelis-Lang/chelis/blob/main/packages/chelis-std/SKILL.md):
  the `chelis-std` API reference.
- [`spec/01-nomenclature.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/01-nomenclature.md):
  the naming conventions `chelis lint` enforces.
- [`spec/design/chelis_canonical_reference.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/chelis_canonical_reference.md):
  the language primer.
