module Hello.Tests.Basics.MacroBasic
import Hello.Basics.MacroBasic (with_residual, doubled, block)
import Std.Test (assert_close_tensor)
def test_block() -> unit ! { Test } = {
  x = to_tensor([1.0f32, 2.0f32])
  expected = to_tensor([2.0f32, 4.0f32])
  assert_close_tensor(block(x), expected, 1e-6f32, "block_doubles")
}
def test_with_residual() -> unit ! { Test } = {
  x = to_tensor([1.0f32, 2.0f32])
  expected = to_tensor([3.0f32, 6.0f32])
  assert_close_tensor(with_residual(x), expected, 1e-6f32, "residual_macro")
}
