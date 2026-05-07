module Hello.Basics.PipeAndMatch

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

// Three pieces of pure language surface:
//
// 1. The pipe operator `|>` is the lowest-precedence binary operator. It
//    threads a value through a function chain left to right. `|> add(b)`
//    means "apply add(_, b)".
//
// 2. ADTs declared with `type T = | A | B | C { field: T }`.
//
// 3. `match scrutinee with { | Pat => expr | ... }`. The compiler checks
//    coverage: a missing arm is a type error, not a warning.

type Activation =
  | Relu
  | Sigmoid

def activate(act: Activation, x: tensor[n, f32]) -> tensor[n, f32] =
  match act with {
    | Relu    => relu(x)
    | Sigmoid => sigmoid(x)
  }

def pipeline(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> relu |> sigmoid

def test_activate_relu() -> unit ! { Test } = {
  x = to_tensor([0.0 - 1.0, 0.0, 2.0])
  out = activate(Relu, x)
  expected = to_tensor([0.0, 0.0, 2.0])
  assert_close_tensor(out, expected, 1e-6, "activate_relu")
}

def test_pipeline() -> unit ! { Test } = {
  x = to_tensor([0.0, 0.0, 0.0])
  out = pipeline(x)
  // sigmoid(0) = 0.5
  expected = to_tensor([0.5, 0.5, 0.5])
  assert_close_tensor(out, expected, 1e-6, "pipeline_zeros")
}
