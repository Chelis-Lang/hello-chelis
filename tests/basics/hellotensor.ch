module Hello.Tests.Basics.HelloTensor
import Hello.Basics.HelloTensor (add_vec)
import Std.Test (assert_close_tensor)
def test_add_vec() -> unit ! { Test } = {
  a = to_tensor([1.0f32, 2.0f32, 3.0f32])
  b = to_tensor([4.0f32, 5.0f32, 6.0f32])
  expected = to_tensor([5.0f32, 7.0f32, 9.0f32])
  assert_close_tensor(add_vec(a, b), expected, 1e-6f32, "add_vec_3")
}
