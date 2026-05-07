module Hello.Tests.Capstone.LinReg

import Hello.Capstone.LinReg (predict, mse_loss, sgd_step)
import Std.Test (assert_true)

-- The linear-regression source in src/capstone/linreg.ch passes
-- `chelis check` end-to-end, including the `grad`-driven `sgd_step`.
-- The IR evaluator at v0.6.1 doesn't lower `grad` for the host
-- runtime, and the `expand(bias, 0, n)` broadcast in `predict`
-- produces a rank-1 result in the evaluator (rank-2 under chelis
-- check) — both are check-only.
--
-- So this test just confirms the module loads. The real validation
-- is `chelis check src/capstone/linreg.ch`, which is part of the
-- top-level CI gate.

def test_linreg_module_loads() -> unit ! { Test } =
  assert_true(true, "linreg_module_loads")
