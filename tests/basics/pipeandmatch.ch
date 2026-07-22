module Hello.Tests.Basics.PipeAndMatch
import Hello.Basics.PipeAndMatch (Activation, activate, pipeline)
import Std.Test (assert_close_tensor)
def shifted(x: &tensor[3, f32]) -> tensor[3, f32] = add(neg(x), to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)]))
def test_activation_pipeline() -> unit ! { Test } = {
  x = to_tensor([cast(-1.0, f32), cast(0.0, f32), cast(1.0, f32)])
  expected = to_tensor([cast(0.5, f32), cast(0.5, f32), cast(0.7310586, f32)])
  assert_close_tensor(pipeline(x), expected, cast(0.000001, f32), "activation_pipeline")
}
def test_pipe_neg_add() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])
  assert_close_tensor(shifted(x), expected, cast(0.000001, f32), "pipe_neg_add")
}
type Op =
  | Plus
  | Minus
def apply(op: Op, x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = {
  match op with {
    | Plus => add(x, y)
    | Minus => add(x, neg(y))
  }
}
def test_apply_plus() -> unit ! { Test } = {
  a = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  expected = to_tensor([cast(4.0, f32), cast(6.0, f32)])
  assert_close_tensor(apply(Plus, a, b), expected, cast(0.000001, f32), "apply_plus")
}
def test_apply_minus() -> unit ! { Test } = {
  a = to_tensor([cast(5.0, f32), cast(7.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  assert_close_tensor(apply(Minus, a, b), expected, cast(0.000001, f32), "apply_minus")
}
