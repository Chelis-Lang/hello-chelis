module Hello.Tests.Basics.Linearity
import Hello.Basics.Linearity (double_shared, fan_out, copy_for_owner)
import Std.Test (assert_close_tensor)
def test_residual_doubles() -> unit ! { Test } = {
  x = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([2.0f32, 4.0f32, 6.0f32])
  assert_close_tensor(double_shared(x), expected, 1e-6f32, "residual_doubles")
}
def test_fan_out_triples() -> unit ! { Test } = {
  x = to_tensor([1.0f32, 2.0f32])
  expected = to_tensor([3.0f32, 6.0f32])
  assert_close_tensor(fan_out(x), expected, 1e-6f32, "fan_out_3x")
}
def test_borrow_needs_copy_for_owned_call() -> unit ! { Test } = {
  x = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([1.0f32, 2.0f32, 3.0f32])
  _ = assert_close_tensor(copy_for_owner(x), expected, 1e-6f32, "copied_for_owner")
  assert_close_tensor(x, expected, 1e-6f32, "borrow_remains_live")
}
