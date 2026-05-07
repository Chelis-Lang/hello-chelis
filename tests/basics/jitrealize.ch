module Hello.Tests.Basics.JitRealize

import Hello.Basics.JitRealize (eager)
import Std.Test (assert_close_tensor)

-- The IR evaluator (`chelis test`) doesn't yet implement `realize` or
-- `jit` lowering. `chelis check` validates both transforms in
-- src/basics/jitrealize.ch; here we exercise the underlying eager
-- function so the runtime test passes.

def test_eager() -> unit ! { Test } = {
  w = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  x = to_tensor([cast(4.0, f32), cast(5.0, f32)])
  expected = to_tensor([cast(8.0, f32), cast(15.0, f32)])
  assert_close_tensor(eager(w, x), expected, cast(1e-6, f32), "eager_mul")
}
