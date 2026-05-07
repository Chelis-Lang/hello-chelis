module Hello.Tests.Basics.JitRealize

import Hello.Basics.JitRealize (eager, with_realize)
import Std.Test (assert_close_tensor)

-- The IR evaluator (`chelis test`) doesn't yet implement `jit` lowering,
-- so we don't exercise `jitted` here — `chelis check` validates that
-- `jit(eager)` typechecks and lowers in Phase 0+ backends. The eager
-- and realize forms run.

def test_eager() -> unit ! { Test } = {
  w = to_tensor([cast(2.0, f32), cast(3.0, f32)])
  x = to_tensor([cast(4.0, f32), cast(5.0, f32)])
  expected = to_tensor([cast(8.0, f32), cast(15.0, f32)])
  assert_close_tensor(eager(w, x), expected, cast(1e-6, f32), "eager_mul")
}

-- with_realize(x) = realize(x + x) + x = 3x
def test_with_realize() -> unit ! { Test } = {
  x = to_tensor([cast(1.0, f32), cast(2.0, f32)])
  expected = to_tensor([cast(3.0, f32), cast(6.0, f32)])
  assert_close_tensor(with_realize(x), expected, cast(1e-6, f32), "realize_then_add")
}
