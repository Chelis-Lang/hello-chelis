module Hello.Tests.Basics.PipeAndMatch

import Hello.Basics.PipeAndMatch (Activation, activate, pipeline)
import Std.Test (assert_close_tensor)

-- The IR evaluator (`chelis test`) doesn't yet ship runtime support for
-- `relu` / `sigmoid` as tensor kernels — those build cleanly via the C
-- backend. Here we exercise the SAME pattern the source file uses (pipe +
-- match) on runtime-supported ops, so the test runs end-to-end.

def shifted(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> neg |> add(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)]))

def test_pipe_neg_add() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])
  assert_close_tensor(shifted(x), expected, cast(1e-6, f32), "pipe_neg_add")
}

-- Match-on-ADT, runtime-runnable arm body (just `add` / `neg`).
type Op = | Plus | Minus

def apply(op: Op, x: tensor[n, f32], y: tensor[n, f32]) -> tensor[n, f32] =
  match op with {
    | Plus  => add(x, y)
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
