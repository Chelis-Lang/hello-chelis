module Hello.Tests.Basics.GradBasic

import Hello.Basics.GradBasic (loss, dloss_dw, dloss_dx)
import Std.Test (assert_close, assert_close_tensor)

-- At w = [2, 2, 2], x = [1, 1, 1]: err = w - 1 = [1, 1, 1]; loss = sum(err*x) = 3
def test_loss_value() -> unit ! { Test } = {
  w = to_tensor([cast(2.0, f32), cast(2.0, f32), cast(2.0, f32)])
  x = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
  assert_close(loss(w, x), cast(3.0, f32), cast(1e-6, f32), "loss_at_w2")
}

-- d/dw [sum((w-1)*x)] = x, evaluated at any w
def test_grad_wrt_w() -> unit ! { Test } = {
  w = to_tensor([cast(5.0, f32), cast(5.0, f32), cast(5.0, f32)])
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  assert_close_tensor(dloss_dw(w, x), expected, cast(1e-5, f32), "grad_wrt_w_eq_x")
}

-- d/dx [sum((w-1)*x)] = w - 1
def test_grad_wrt_x() -> unit ! { Test } = {
  w = to_tensor([cast(2.0, f32), cast(3.0, f32), cast(4.0, f32)])
  x = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])
  expected = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  assert_close_tensor(dloss_dx(w, x), expected, cast(1e-5, f32), "grad_wrt_x_eq_w_minus_1")
}
