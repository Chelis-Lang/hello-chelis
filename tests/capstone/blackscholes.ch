module Hello.Tests.Capstone.BlackScholes

import Hello.Capstone.BlackScholes (call_price)
import Std.Test (assert_close)

-- Standard at-the-money call: S=K=100, r=5%, sigma=20%, T=1 year.
-- Closed-form C ≈ 10.4506.
--
-- The Greeks (delta, vega, rho) are derived via `grad` in
-- src/capstone/blackscholes.ch — `chelis check` validates them, but
-- the IR evaluator at v0.6.1 doesn't lower `grad` for the host
-- runtime. They run via `chelis build --target c`.

def test_call_atm() -> unit ! { Test } =
  assert_close(
    call_price(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.20, f32), cast(1.0, f32)),
    cast(10.4506, f32),
    cast(0.05, f32),
    "bs_call_atm"
  )
