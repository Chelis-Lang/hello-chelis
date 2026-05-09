module Hello.Tests.Basics.PipeAndMatch
import Hello.Basics.PipeAndMatch (Activation, activate, pipeline)
import Std.Test (assert_close_tensor)
def shifted(x: &tensor[n, f32]) -> tensor[n, f32] = x |> neg |> add(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)]))
def test_pipe_neg_add() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(shifted(x), expected, cast(0.000001, f32), "pipe_neg_add")
  _ = drop(x)
  _ = drop(expected)
  __borrow_migration_out_0
}
type Op =
  | Plus
  | Minus
def apply(op: Op, x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = { match op with {
  | Plus => add(x, y)
  | Minus => add(x, neg(y))
} }
def test_apply_plus() -> unit ! { Test } = {
  a = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  expected = to_tensor([cast(4.0, f32), cast(6.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(apply(Plus, a, b), expected, cast(0.000001, f32), "apply_plus")
  _ = drop(a)
  _ = drop(b)
  _ = drop(expected)
  __borrow_migration_out_0
}
def test_apply_minus() -> unit ! { Test } = {
  a = to_tensor([cast(5.0, f32), cast(7.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(4.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  __borrow_migration_out_1 = assert_close_tensor(apply(Minus, a, b), expected, cast(0.000001, f32), "apply_minus")
  _ = drop(a)
  _ = drop(b)
  _ = drop(expected)
  __borrow_migration_out_1
}
