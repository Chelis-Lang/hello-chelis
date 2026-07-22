module Hello.Tests.Basics.GradBasic
import Hello.Basics.GradBasic (dloss_dw, dloss_dx)
import Std.Test (assert_close_tensor)
def test_grad_w() -> unit ! { Test } = {
  w = to_tensor([cast(0.5, f32), cast(0.5, f32), cast(0.5, f32)])
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  assert_close_tensor(dloss_dw(w, x), expected, cast(0.000001, f32), "grad_w")
}
def test_grad_x() -> unit ! { Test } = {
  w = to_tensor([cast(0.5, f32), cast(0.5, f32), cast(0.5, f32)])
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(-0.5, f32), cast(-0.5, f32), cast(-0.5, f32)])
  assert_close_tensor(dloss_dx(w, x), expected, cast(0.000001, f32), "grad_x")
}
