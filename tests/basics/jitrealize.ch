module Hello.Tests.Basics.JitRealize
import Hello.Basics.JitRealize (eager, with_realize)
import Std.Test (assert_close_tensor)
def test_eager() -> unit ! { Test } = {
  w = to_tensor([2.0f32, 3.0f32])
  x = to_tensor([4.0f32, 5.0f32])
  expected = to_tensor([8.0f32, 15.0f32])
  assert_close_tensor(eager(w, x), expected, 1e-6f32, "eager_mul")
}
def test_with_realize() -> unit ! { Test } = {
  x = to_tensor([1.0f32, 2.0f32])
  expected = to_tensor([3.0f32, 6.0f32])
  assert_close_tensor(with_realize(x), expected, 1e-6f32, "with_realize")
}
