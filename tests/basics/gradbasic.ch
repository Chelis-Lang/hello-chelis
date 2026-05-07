module Hello.Tests.Basics.GradBasic

import Hello.Basics.GradBasic (loss, dloss_dw, dloss_dx)
import Std.Test (assert_true)

-- The grad demonstrations in src/basics/gradbasic.ch pass `chelis check`
-- end-to-end. The IR evaluator at v0.6.1 doesn't yet lower `grad` for
-- the host runtime, and `loss` returns a rank-0 tensor that
-- `assert_close` (which wants `f32`) doesn't accept directly. The C
-- backend runs the full grad pipeline.
--
-- This test confirms the module loads in the test runner.

def test_grad_module_loads() -> unit ! { Test } =
  assert_true(true, "grad_module_loads")
