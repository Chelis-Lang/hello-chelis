module Hello.Basics.Linearity

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

// Tensors are consume-by-default. Passing `x` to a function consumes `x`;
// any subsequent reference is a `UseAfterConsume` compile error. Two
// escape hatches:
//
//   - `copy(x)` — produce a fresh tensor that can be consumed again. Tells
//     the compiler to set up two gradient accumulators.
//   - `&x` — borrow `x` read-only as a direct call argument. Cannot be
//     stored, returned, rebound, or captured.
//
// This is what makes residual connections (and any fan-out) sound: every
// branch of the fan-out must say so explicitly via `copy`.

// Correct: a residual block that uses `x` twice. Without the `copy`, the
// second `x` would be a use-after-consume.
def residual(x: tensor[n, f32]) -> tensor[n, f32] = {
  y = relu(copy(x))
  add(x, y)
}

// Correct: borrow when you don't need a second writeable copy.
def borrowed(x: tensor[n, f32]) -> tensor[n, f32] = {
  y = relu(&x)
  add(x, y)
}

def test_residual() -> unit ! { Test } = {
  x = to_tensor([0.0 - 1.0, 0.0, 2.0])
  out = residual(x)
  // x = [-1, 0, 2]; relu(x) = [0, 0, 2]; sum = [-1, 0, 4]
  expected = to_tensor([0.0 - 1.0, 0.0, 4.0])
  assert_close_tensor(out, expected, 1e-6, "residual")
}

def test_borrowed_matches_residual() -> unit ! { Test } = {
  x = to_tensor([0.0 - 1.0, 0.0, 2.0])
  out_a = residual(x)
  // Re-construct because `residual` consumed its argument.
  out_b = borrowed(to_tensor([0.0 - 1.0, 0.0, 2.0]))
  assert_close_tensor(out_a, out_b, 1e-6, "residual_eq_borrowed")
}

// Note: the deliberately broken `def use_after_consume(x) = { y = relu(x); add(x, y) }`
// is captured under tests/expected/use_after_consume_should_fail.json,
// which asserts the compiler rejects it with the `UseAfterConsume`
// diagnostic and the canonical "insert copy(x)" hint.
