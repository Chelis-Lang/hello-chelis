module Hello.Tests.Basics.ModulesAndImports
import Hello.Basics.ModulesAndImports.Util (double, ones3)
import Hello.Basics.ModulesAndImports.Main (boost)
import Std.Test (assert_close_tensor)
def test_double() -> unit ! { Test } = {
  v = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(double(v), expected, cast(0.000001, f32), "double")
  _ = drop(v)
  _ = drop(expected)
  __borrow_migration_out_0
}
def test_ones3() -> unit ! { Test } = {
  expected = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(ones3(), expected, cast(0.000001, f32), "ones3")
  _ = drop(expected)
  __borrow_migration_out_0
}
def test_boost() -> unit ! { Test } = {
  expected = to_tensor([cast(4.0, f32), cast(4.0, f32), cast(4.0, f32)])
  __borrow_migration_out_1 = assert_close_tensor(boost(), expected, cast(0.000001, f32), "boost")
  _ = drop(expected)
  __borrow_migration_out_1
}
