module Hello.Tests.Basics.Linearity
import Hello.Basics.Linearity (residual, fan_out)
import Std.Test (assert_close_tensor)
def test_residual_doubles() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(residual(x), expected, cast(0.000001, f32), "residual_doubles")
  _ = drop(expected)
  _ = drop(x)
  __borrow_migration_out_0
}
def test_fan_out_triples() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  expected = to_tensor([cast(3.0, f32), cast(6.0, f32)])
  __borrow_migration_out_1 = assert_close_tensor(fan_out(x), expected, cast(0.000001, f32), "fan_out_3x")
  _ = drop(expected)
  _ = drop(x)
  __borrow_migration_out_1
}
