module Hello.Basics.JitRealize

export (eager, with_realize)

-- A small linear-style function over an `n`-vector.
def eager(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[n, f32] =
  mul(w, x)

-- `realize(e)` forces evaluation of an otherwise-deferred expression,
-- giving the compiler an explicit sequencing point in a fused chain.
-- Used when fusion would otherwise hold the value as a thunk.
def with_realize(x: tensor[n, f32]) -> tensor[n, f32] = {
  doubled = realize(add(copy(x), copy(x)))
  add(doubled, x)
}

-- The `jit(f)` transform also exists at the language level (it lifts `f`
-- into the build-target form so a specialized DAG is compiled once and
-- reused). The IR evaluator used by `chelis test` doesn't lower `jit` at
-- v0.6.1, so we keep the demo to a check-only file:
-- see `examples/jitcheck.dp` in the upstream chelis repo.
