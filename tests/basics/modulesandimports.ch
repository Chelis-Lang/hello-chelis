module Hello.Tests.Basics.ModulesAndImports
import Hello.Basics.ModulesAndImports.Util (double, ones3)
import Hello.Basics.ModulesAndImports.Main (boost)
import Std.Test (assert_close_tensor)
def test_double() -> unit ! { Test } = {
  v = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([2.0f32, 4.0f32, 6.0f32])
  assert_close_tensor(double(v), expected, 1e-6f32, "double")
}
def test_ones3() -> unit ! { Test } = {
  expected = to_tensor([1.0f32, 1.0f32, 1.0f32])
  assert_close_tensor(ones3(), expected, 1e-6f32, "ones3")
}
def test_boost() -> unit ! { Test } = {
  expected = to_tensor([4.0f32, 4.0f32, 4.0f32])
  assert_close_tensor(boost(), expected, 1e-6f32, "boost")
}
