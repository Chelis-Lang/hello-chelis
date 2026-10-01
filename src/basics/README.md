# `src/basics/`: language fundamentals

The core language, using only `chelis-std` (which ships with the compiler).
Read these before the packages. Each file has a `.dp` sibling (its Deep form)
and a test of the same name under [`tests/basics/`](../../tests/basics/).

## Reading order

| Step | File | What it teaches |
|---|---|---|
| 1 | [`hellotensor.ch`](hellotensor.ch) | tensor dimensions in the type, no implicit broadcasting |
| 2 | [`pipeandmatch.ch`](pipeandmatch.ch) | an ADT, exhaustive `match`, the `\|>` pipe, tensor `relu` / `sigmoid` |
| 3 | [`modulesandimports/`](modulesandimports/) | a multi-file module; selective and glob imports |
| 4 | [`dimpoly.ch`](dimpoly.ch) | dimension-polymorphic functions with `[a]` binders |
| 5 | [`precisioncast.ch`](precisioncast.ch) | no implicit precision promotion; explicit `cast` |
| 6 | [`effectsrandom.ch`](effectsrandom.ch) | explicit keys, deterministic replay, and independent draws via `split_key` |
| 7 | [`linearity.ch`](linearity.ch) | reading a tensor several times through `&` borrows |
| 8 | [`gradbasic.ch`](gradbasic.ch) | `grad(loss, wrt=w)` on a scalar loss |
| 9 | [`vmap.ch`](vmap.ch) | lifting a per-example function over a batch dimension |
| 10 | [`jitrealize.ch`](jitrealize.ch) | forcing evaluation with `realize`, next to an eager baseline |
| 11 | [`macrobasic.ch`](macrobasic.ch) | the prelude `residual` macro, expanded to typed Deep at compile time |

`chelis test tests/basics/` runs the assertions for every file.
[`../../verify/`](../../verify/) compiles `grad`, `realize`, `cast`, and the
activations to C and runs them.
