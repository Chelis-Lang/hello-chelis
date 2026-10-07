module Hello.Tests.Basics.PipeAndMatch
import Hello.Basics.PipeAndMatch (Activation, Relu, Sigmoid, activate, pipeline)
import Std.Test (assert_close_tensor)
def test_activate_relu() -> unit ! { Test } = {
  x = to_tensor([-1.0f32, 2.0f32])
  expected = to_tensor([0.0f32, 2.0f32])
  assert_close_tensor(activate(Relu, x), expected, 1e-6f32, "activate_relu")
}
def test_activate_sigmoid() -> unit ! { Test } = {
  x = to_tensor([0.0f32, 0.0f32])
  expected = to_tensor([0.5f32, 0.5f32])
  assert_close_tensor(activate(Sigmoid, x), expected, 1e-6f32, "activate_sigmoid")
}
def test_pipeline_relu_then_sigmoid() -> unit ! { Test } = {
  x = to_tensor([-1.0f32, 0.0f32])
  expected = to_tensor([0.5f32, 0.5f32])
  assert_close_tensor(pipeline(x), expected, 1e-6f32, "pipeline")
}
type Op =
  | Plus
  | Minus
def apply[n](op: Op, x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] =
  match op with {
    | Plus => add(x, y)
    | Minus => add(x, neg(y))
  }
def test_apply_plus() -> unit ! { Test } = {
  a = to_tensor([1.0f32, 2.0f32])
  b = to_tensor([3.0f32, 4.0f32])
  expected = to_tensor([4.0f32, 6.0f32])
  assert_close_tensor(apply(Plus, a, b), expected, 1e-6f32, "apply_plus")
}
def test_apply_minus() -> unit ! { Test } = {
  a = to_tensor([5.0f32, 7.0f32])
  b = to_tensor([3.0f32, 4.0f32])
  expected = to_tensor([2.0f32, 3.0f32])
  assert_close_tensor(apply(Minus, a, b), expected, 1e-6f32, "apply_minus")
}
