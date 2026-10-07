# Tour the repository

This page is a map of the hello-chelis repository: where each topic lives.
The [five lessons](curriculum.md) and [Read a larger
calculation](capstones.md) teach the calls themselves. Nearly every
module under `src/` has a test of the same name under `tests/` with fixed
inputs and expected values. To run any module, follow the [setup on the
capstones page](capstones.md#set-up-the-package) and call its
exported functions from a file in the checkout's root.

## Language fundamentals

[`src/basics/`](https://github.com/Chelis-Lang/hello-chelis/tree/main/src/basics)
has one small module per feature:

| Module | What it shows |
|---|---|
| `hellotensor` | Dimensions in the type, and no implicit broadcasting. |
| `pipeandmatch` | An algebraic data type, an exhaustive `match`, and the `\|>` pipe. |
| `modulesandimports` | Selective and glob imports. |
| `dimpoly` | Functions polymorphic over dimensions. |
| `precisioncast` | Explicit `cast` between precisions. |
| `effectsrandom` | Explicit random keys, deterministic replay, and `split_key`. |
| `linearity` | Owned tensors, `&tensor` borrows, and `copy`. |
| `gradbasic` | `grad(f, wrt=w)`. |
| `vmap` | Lifting a per-example function over a batch. |
| `jitrealize` | `realize` beside an eager baseline. |
| `macrobasic` | A macro that expands to typed Deep. |

## Standard library

[`src/std/`](https://github.com/Chelis-Lang/hello-chelis/tree/main/src/std)
covers elementwise math, normalization, axis reductions, exact `Decimal`
arithmetic, dates, collections and iteration, and effect-typed file I/O. The
[runtime and standard library reference](https://chelis.ch/docs/chelis/stdlib/) teaches
these calls, with signatures, argument domains and failure behavior.

## Packages

[`src/coral/`](https://github.com/Chelis-Lang/hello-chelis/tree/main/src/coral)
uses [Coral](https://chelis.ch/docs/coral/): typed columns, `group_by`, joins, rolling windows,
reshape, and CSV and JSON I/O. The [Coral docs](https://chelis.ch/docs/coral/) teach
each of these calls.

[`src/nautilus/`](https://github.com/Chelis-Lang/hello-chelis/tree/main/src/nautilus)
calls [Nautilus](https://chelis.ch/docs/nautilus/): special functions, distributions, linear
algebra, ODE and SDE solvers, optimization, hypothesis tests and curve fitting.
The [Nautilus docs](https://chelis.ch/docs/nautilus/) give their signatures and worked calls.

## Capstones

Beside the three modules on [Read a larger
calculation](capstones.md),
[`src/capstone/`](https://github.com/Chelis-Lang/hello-chelis/tree/main/src/capstone)
has three calculations built on [Shoals](https://chelis.ch/docs/shoals/), the Chelis library
for quantitative finance (curves, option pricing and risk):

- `yieldcurve` bootstraps a zero curve from par yields, prices a bond on it,
  and computes DV01 and key-rate risk.
- `americanput` prices one American put three ways: a binomial tree, a
  Crank-Nicolson grid, and Barone-Adesi-Whaley solved with a Nautilus root
  finder.
- `varbacktest` computes historical and parametric VaR and CVaR, and runs
  Kupiec and Christoffersen backtests of a rolling and an EWMA model.

The [Shoals docs](https://chelis.ch/docs/shoals/) teach the curve, pricing and risk calls
these modules use.

## Compiled programs

[`verify/`](https://github.com/Chelis-Lang/hello-chelis/tree/main/verify)
holds standalone programs that `chelis build` compiles to native code, links
against the Chelis runtime, and runs.
