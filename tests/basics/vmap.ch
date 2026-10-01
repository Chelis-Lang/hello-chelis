module Hello.Tests.Basics.Vmap
import Hello.Basics.Vmap (process, batch_process)
import Std.Test (assert_close_tensor)
def test_process_doubles() -> unit ! { Test } = {
  v = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([2.0f32, 4.0f32, 6.0f32])
  assert_close_tensor(process(v), expected, 1e-6f32, "process_doubles")
}
