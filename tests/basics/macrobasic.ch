module Hello.Tests.Basics.MacroBasic
import Hello.Basics.MacroBasic (with_residual, doubled, block)
import Std.Test (assert_close_tensor)
def test_block() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(block(x), expected, cast(0.000001, f32), "block_doubles")
  __borrow_migration_out_0
}
def test_with_residual() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  expected = to_tensor([cast(3.0, f32), cast(6.0, f32)])
  __borrow_migration_out_1 = assert_close_tensor(with_residual(x), expected, cast(0.000001, f32), "residual_macro")
  __borrow_migration_out_1
}
