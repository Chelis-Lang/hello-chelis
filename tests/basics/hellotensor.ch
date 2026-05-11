module Hello.Tests.Basics.HelloTensor
import Hello.Basics.HelloTensor (add_vec)
import Std.Test (assert_close_tensor)
def test_add_vec() -> unit ! { Test } = {
  a = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  b = to_tensor([cast(4.0, f32), cast(5.0, f32), cast(6.0, f32)])
  expected = to_tensor([cast(5.0, f32), cast(7.0, f32), cast(9.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(add_vec(a, b), expected, cast(0.000001, f32), "add_vec_3")
  __borrow_migration_out_0
}
