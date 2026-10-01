module Hello.Tests.Basics.PipeAndMatch
import Hello.Basics.PipeAndMatch (Activation, Relu, Sigmoid, activate, pipeline)
import Std.Test (assert_close_tensor)
def test_activate_relu() -> unit ! { Test } = {
  x = to_tensor([cast(-1.0, f32), cast(2.0, f32)])
  expected = to_tensor([cast(0.0, f32), cast(2.0, f32)])
  assert_close_tensor(activate(Relu, x), expected, cast(1e-6, f32), "activate_relu")
}
def test_activate_sigmoid() -> unit ! { Test } = {
  x = to_tensor([cast(0.0, f32), cast(0.0, f32)])
  expected = to_tensor([cast(0.5, f32), cast(0.5, f32)])
  assert_close_tensor(activate(Sigmoid, x), expected, cast(1e-6, f32), "activate_sigmoid")
}
def test_pipeline_relu_then_sigmoid() -> unit ! { Test } = {
  x = to_tensor([cast(-1.0, f32), cast(0.0, f32)])
  expected = to_tensor([cast(0.5, f32), cast(0.5, f32)])
  assert_close_tensor(pipeline(x), expected, cast(1e-6, f32), "pipeline")
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
  a = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  expected = to_tensor([cast(4.0, f32), cast(6.0, f32)])
  assert_close_tensor(apply(Plus, a, b), expected, cast(1e-6, f32), "apply_plus")
}
def test_apply_minus() -> unit ! { Test } = {
  a = to_tensor([cast(5.0, f32), cast(7.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  assert_close_tensor(apply(Minus, a, b), expected, cast(1e-6, f32), "apply_minus")
}
