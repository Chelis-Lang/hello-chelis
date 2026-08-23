module Hello.Tests.Basics.ModulesAndImports
import Hello.Basics.ModulesAndImports.Util (double, ones3)
import Hello.Basics.ModulesAndImports.Main (boost)
import Std.Test (assert_close_tensor)
def test_double() -> unit ! { Test } = {
  v = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  assert_close_tensor(double(v), expected, cast(1e-6, f32), "double")
}
def test_ones3() -> unit ! { Test } = {
  expected = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
  assert_close_tensor(ones3(), expected, cast(1e-6, f32), "ones3")
}
def test_boost() -> unit ! { Test } = {
  expected = to_tensor([cast(4.0, f32), cast(4.0, f32), cast(4.0, f32)])
  assert_close_tensor(boost(), expected, cast(1e-6, f32), "boost")
}
