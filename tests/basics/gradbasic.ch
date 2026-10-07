module Hello.Tests.Basics.GradBasic
import Hello.Basics.GradBasic (dloss_dw, dloss_dx)
import Std.Test (assert_close_tensor)
def test_dloss_dw_is_x() -> unit ! { Test } = {
  w = to_tensor([0.5f32, 0.5f32, 0.5f32])
  x = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([1.0f32, 2.0f32, 3.0f32])
  assert_close_tensor(dloss_dw(w, x), expected, 1e-6f32, "dloss_dw")
}
def test_dloss_dx_is_w_minus_one() -> unit ! { Test } = {
  w = to_tensor([0.5f32, 2.0f32, 3.0f32])
  x = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([-0.5f32, 1.0f32, 2.0f32])
  assert_close_tensor(dloss_dx(w, x), expected, 1e-6f32, "dloss_dx")
}
