module Hello.Tests.Basics.JitRealize
import Hello.Basics.JitRealize (eager)
import Std.Test (assert_close_tensor)
def test_eager() -> unit ! { Test } = {
  w = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  x = to_tensor([cast(4.0, f32), cast(5.0, f32)])
  expected = to_tensor([cast(8.0, f32), cast(15.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(eager(w, x), expected, cast(0.000001, f32), "eager_mul")
  _ = drop(expected)
  _ = drop(w)
  _ = drop(x)
  __borrow_migration_out_0
}
