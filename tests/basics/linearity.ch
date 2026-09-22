module Hello.Tests.Basics.Linearity
import Hello.Basics.Linearity (double_shared, fan_out)
import Std.Test (assert_close_tensor)
def test_residual_doubles() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  assert_close_tensor(double_shared(x), expected, cast(1e-6, f32), "residual_doubles")
}
def test_fan_out_triples() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  expected = to_tensor([cast(3.0, f32), cast(6.0, f32)])
  assert_close_tensor(fan_out(x), expected, cast(1e-6, f32), "fan_out_3x")
}
