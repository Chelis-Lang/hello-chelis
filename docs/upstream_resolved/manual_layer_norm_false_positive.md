# `manual_layer_norm` linearity flag: resolved as scout false-positive

> Historical resolved record. Version and machine-path details below document
> the original Chelis 0.7.10 investigation, not current installation guidance.

## Context

`src/std/activationsnorms.ch:16-26` defines `manual_layer_norm`. A scouting pass
flagged a suspected linearity violation:

- Line 21: `centered = map(fn (v: f32) -> sub(v, mu), to_list(x))` is bound with
  type `List[f32]`.
- Line 22: `sq_sum = fold(fn (acc, v) -> add(acc, mul(v, v)), cast(0.0, f32), centered)`
  passes `centered` to `fold` (suspected to consume).
- Line 25: `to_tensor(map(fn (v: f32) -> mul(v, inv_std), centered))` reuses
  `centered` after the `fold`.

Hypothesis: `fold` consumes its list argument, so `centered` is consumed on
L22 and reused on L25, which the linearity checker should reject. hello-chelis
0.1.6 passes `chelis check`, so either (a) `fold` actually borrows, or (b) the
checker has a gap on this shape.

## Verification (chelis 0.7.10)

Binary: `/home/jeff/Documents/scratch/chelis/target/release/chelis` (0.7.10).

### Minimal reproducer

```surf
module Repro
export (test)
def test() -> f32 = {
  xs = to_list(to_tensor([cast(1.0, f32), cast(2.0, f32)]))
  s = fold(fn (acc: f32, v: f32) -> add(acc, v), cast(0.0, f32), xs)
  fold(fn (acc: f32, v: f32) -> add(acc, mul(v, v)), cast(0.0, f32), xs)
}
```

Running `chelis check` on this file: no errors. Only an unrelated
`prefer-pipe-operator` style warning.

Running `chelis check` on `src/std/activationsnorms.ch` directly: no errors.

Both behave identically, so the verification is conclusive: the checker is
not failing to fire; there is no violation to fire on.

## Root cause: `List[f32]` is not an owned-linear type

The chelis linearity pass (`crates/chelis-types/src/linearity.rs`) only
tracks values whose type **contains a tensor**. From the source:

```rust
// linearity.rs:1513-1524
fn type_expr_contains_tensor(expr: &Expr) -> bool {
    let Expr::List(list, _) = expr else { return false };
    match get_tag(list) {
        Some("t-tensor") => true,
        Some("t-ref") => children(list).iter().any(type_expr_contains_tensor),
        Some("t-tuple") | Some("t-adt") => children(list).iter().any(type_expr_contains_tensor),
        Some("t-fn") => false,
        _ => false,
    }
}

// linearity.rs:1530-1532
fn type_expr_is_owned_linear(expr: &Expr) -> bool {
    type_expr_contains_tensor(expr) && !type_expr_is_ref(expr)
}
```

`List[f32]` (a `t-adt` with `t-f32` inside, no `t-tensor`) returns `false`
from `type_expr_contains_tensor` and therefore `false` from
`type_expr_is_owned_linear`. Such values are non-linear at the linearity
level: freely copyable, no consume-tracking. `fold` consuming a `List[f32]`
is a no-op from the checker's perspective; reusing the binding on the next
line is allowed.

`to_list(x)` (where `x: &tensor[n, f32]`) returns a `List[f32]`, which is
the type of `centered` at L21 after a `map`. The whole pipeline operates on
host-side scalar lists, none of which the linearity pass treats as linear.

The `fold` builtin's *type* signature is owned for all three args
(`crates/chelis-types/src/builtins.rs:823-840` registers via `generic_triop`,
not a borrow-tagged variant; `crates/chelis-types/src/infer.rs:8177-8217`
unifies the list arg as `List[elem]` with no borrow marker). The
linearity-vs-type distinction is what saves this code: types say "consumed",
linearity says "not tracked".

A consume-then-reuse on a *tensor-carrying* List (e.g., `List[tensor[k, f32]]`)
would in principle be tracked; that's a different pattern and not what
`manual_layer_norm` exercises.

## Conclusion

Scout heuristic was overzealous: it pattern-matched `fold(..., centered);
... map(..., centered)` without considering whether `centered`'s type is
owned-linear. For `List[f32]`, it isn't. No source change needed.

Closed: 2026-05-22 (WS-D, cleanup wave).
