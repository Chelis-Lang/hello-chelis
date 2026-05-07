module Hello.Basics.Linearity

export (residual, fan_out)

-- Tensors are consume-by-default. Passing `x` to a function consumes it;
-- referring to `x` again is a `UseAfterConsume` compile error. The
-- escape hatch is `copy(x)`, which produces a fresh tensor that can be
-- consumed independently. The compiler uses this fan-out marker to
-- set up the right gradient accumulators in any `grad`-derived backward
-- pass.

-- A residual block: `x` is used twice. The explicit `copy(x)` is what
-- makes the use-after-consume rule satisfied — `add` consumes the copy
-- on the first arg, and the original `x` on the second.
def residual(x: tensor[n, f32]) -> tensor[n, f32] =
  add(copy(x), x)

-- Triple fan-out: the input feeds three separate consumers, so we make
-- three copies in a chain. The compiler emits proper backward-pass
-- accumulation across all three branches when this is grad'd.
def fan_out(x: tensor[n, f32]) -> tensor[n, f32] = {
  a = copy(x)
  b = copy(x)
  c = x
  add(a, add(b, c))
}
