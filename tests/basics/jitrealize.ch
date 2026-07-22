module Hello.Tests.Basics.JitRealize
import Hello.Basics.JitRealize (eager, with_realize)
import Std.Test (assert_close_tensor)
def test_eager() -> unit ! { Test } = {
  w = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  x = to_tensor([cast(4.0, f32), cast(5.0, f32)])
  expected = to_tensor([cast(8.0, f32), cast(15.0, f32)])
  assert_close_tensor(eager(w, x), expected, cast(0.000001, f32), "eager_mul")
}
def test_realize() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  expected = to_tensor([cast(3.0, f32), cast(6.0, f32)])
  assert_close_tensor(with_realize(x), expected, cast(0.000001, f32), "realize")
}
