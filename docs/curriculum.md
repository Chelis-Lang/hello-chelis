# Curriculum — learning Chelis from this repo

A reading path through the corpus, ordered for someone who knows
typed FP (OCaml / Haskell / Rust) and a tensor framework (PyTorch /
JAX / Flax) but has never seen Chelis before. Each step references
the file(s) you should open and what they teach.

If you'd rather just run things, see
[`getting_started.md`](getting_started.md). Architecture-level
context lives in [`architecture.md`](architecture.md).

## 0. Mental model (5 min)

Read the [README](../README.md) `## What this is` section. Then read
[`surf_and_deep.md`](surf_and_deep.md). Two source surfaces over the
same AST is the language's most distinctive shape decision. Every
program in this repo ships in both forms.

## 1. The compiler's three execution paths (10 min)

Skim [`discrepancies.md`](discrepancies.md). **`chelis check`,
`chelis test` (the IR evaluator), and `chelis build --target c` remain
separate acceptors.** Most historical gaps closed by `0.16.1`; current
exceptions are executable expected failures under `tests_blocked/`.

## 2. Language fundamentals (60 min)

Walk [`src/basics/`](../src/basics/) in order. Each file is small
and self-contained:

1. [`hellotensor.ch`](../src/basics/hellotensor.ch) — named
   dimensions, no implicit broadcasting. Compare the Surf to the
   sibling `.dp` to see how `tensor[n, f32]` desugars.
2. [`pipeandmatch.ch`](../src/basics/pipeandmatch.ch) — ADTs are
   exhaustively matched; piped tensor activation chains execute in both
   evaluator and C lanes.
3. [`modulesandimports/`](../src/basics/modulesandimports/) — the
   three import forms (qualified, selective, glob).
4. [`dimpoly.ch`](../src/basics/dimpoly.ch) — bracketed dim
   parameters `[a, b]` for polymorphic functions.
5. [`precisioncast.ch`](../src/basics/precisioncast.ch) — no implicit
   precision promotion.
6. [`effectsrandom.ch`](../src/basics/effectsrandom.ch) — `! { Random
   }` effect rows; `with seed(...)` algebraic handler.
7. [`linearity.ch`](../src/basics/linearity.ch) — consume-by-default,
   explicit `copy(x)` compatibility, and `&borrow` for read-only use.
8. [`gradbasic.ch`](../src/basics/gradbasic.ch) — `grad(f, wrt=w)`
   reverse-mode AD on a scalar loss.
9. [`vmap.ch`](../src/basics/vmap.ch) — per-example function batched
   over a new dimension.
10. [`jitrealize.ch`](../src/basics/jitrealize.ch) — `jit` and
    `realize` transforms.
11. [`macrobasic.ch`](../src/basics/macrobasic.ch) — compile-time
    expansion to typed Deep.

For each file, also open the matching `tests/basics/<name>.ch` to
see how the assertion runs. The 11 src files map 1:1 to 11 test
files.

Then look at the corresponding `<name>.dp` (the canonical Deep) to
see exactly how the desugaring rules in
[`spec/02-surf-syntax.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/02-surf-syntax.md)
play out on real programs.

## 3. The standard library (30 min)

[`src/std/`](../src/std/) tours `chelis-std`'s six biggest surfaces:

- activations + normalizations
- reductions + losses
- decimal arithmetic with compile-time precision
- datetime / calendar
- collections + iteration combinators
- tensor I/O (effect-typed `! { IO }`)

Open the per-area README at
[`src/std/README.md`](../src/std/README.md) for the catalog. Read
each file alongside its sibling test in `tests/std/<name>.ch`.

## 4. The shells (90 min — pick whichever applies to your work)

Three shipped third-party shells, each demonstrating Chelis as a
substrate for a different domain:

### Coral — typed dataframes

[`src/coral/`](../src/coral/) — pandas-equivalent surfaces. The
example combines typed Frame construction with a separately executable direct
tensor gradient. It does not overclaim AD through joins or `group_by`. See
[`adthroughdataframe.ch`](../src/coral/adthroughdataframe.ch).

### Nautilus — numerics

[`src/nautilus/`](../src/nautilus/) — scipy-equivalent. 13 modules
covering special functions, distributions, linear algebra, ODE/SDE
integration, optimization, hypothesis testing, curve fitting. Pure
Chelis, so AD flows through every method via tensor-op composition.

### Octant — LaTeX bridge

[`octant/`](../octant/) — translates a bounded subset of math LaTeX
into canonical Deep. Each program is committed as a LaTeX/Deep/spans/
Surf quadruple. Read [`octant/README.md`](../octant/README.md) for
the catalog. The notable property: `chelis surf <file>.dp` decompiles
the translated Deep back into readable Chelis.

### c-earchin — EARS requirements bridge

[`docs/shells/c_earchin.md`](shells/c_earchin.md) points to the
finance-options demo in the c-earchin repo. It shows natural-language EARS
requirements translated to Deep property witnesses, proven by `chelis prove`,
with failure diagnostics resolving back to the EARS line.

## 5. Capstones (45 min)

[`src/capstone/`](../src/capstone/) — multi-shell integrations:

- [`blackscholes.ch`](../src/capstone/blackscholes.ch): Black-Scholes
  call price plus visible `grad`-defined Greeks. Call price executes; the
  exact-value Greek probe remains in `tests_blocked/`. Cross-reference to the LaTeX form
  at [`octant/black_scholes_d1.tex`](../octant/black_scholes_d1.tex).
- [`linreg.ch`](../src/capstone/linreg.ch): linear regression with
  predict / loss / SGD step.
- [`mlpipeline.ch`](../src/capstone/mlpipeline.ch): end-to-end CSV
  → features → loss → statistics across `chelis-std` + `coral` +
  `nautilus`.
- [`transformerblock.ch`](../src/capstone/transformerblock.ch): the
  primer's transformer block, with explicit `copy(x)` at fan-out sites
  retained as migration-compatible style.

## 6. Verifying full lowering (20 min)

[`verify/`](../verify/) holds project-free programs that build to C,
link, and run end-to-end. Read [`verify/README.md`](../verify/README.md).
These independent goldens ensure direct grad, tensor activations, realize, and
casts continue to work through generated C even though they now also execute in
the evaluator.

```sh
python3 -m pytest -q tests/test_c_backend.py
```

builds each `verify/*.ch` to C, links against `libchelis_runtime.a`
and OpenBLAS, runs, and diffs stdout against the committed golden in
`verify/expected/<name>.txt`.

## 7. Why the dual format (final 5 min)

Re-read [`surf_and_deep.md`](surf_and_deep.md) once you've seen 50+
Surf programs and their Deep counterparts in the wild. The
illustrative payoff lands harder once you've internalized the
desugaring on your own examples.

For the proper compiler-vs-runtime gap inventory, end with
[`discrepancies.md`](discrepancies.md). The deltas there are the
real edges of the pinned toolchain surface.

## Where to look for the source-of-truth specs upstream

- [`spec/02-surf-syntax.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/02-surf-syntax.md)
  — the Surf grammar + desugaring rules.
- [`packages/chelis-std/SKILL.md`](https://github.com/Chelis-Lang/chelis/blob/main/packages/chelis-std/SKILL.md)
  — the chelis-std API reference.
- [`spec/01-nomenclature.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/01-nomenclature.md)
  — naming conventions enforced by `chelis lint`.
- The Chelis primer:
  [`spec/design/chelis_canonical_reference.md`](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/chelis_canonical_reference.md).
