module Hello.Tests.Basics.Vmap
import Hello.Basics.Vmap (process, batch_process)
import Std.Test (assert_close_tensor)
def test_process_doubles() -> unit ! { Test } = {
  v = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  __borrow_migration_out_0 = assert_close_tensor(process(v), expected, cast(0.000001, f32), "process_doubles")
  _ = drop(v)
  _ = drop(expected)
  __borrow_migration_out_0
}
