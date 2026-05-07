module Hello.Tests.Capstone.BlackScholes

import Hello.Capstone.BlackScholes (call_price, delta, vega)
import Std.Test (assert_close)

-- Standard at-the-money call: S=K=100, r=5%, sigma=20%, T=1 year.
-- Closed-form C ≈ 10.4506. Delta ≈ 0.6368. Vega ≈ 37.524.

def test_call_atm() -> unit ! { Test } =
  assert_close(
    call_price(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.20, f32), cast(1.0, f32)),
    cast(10.4506, f32),
    cast(0.05, f32),
    "bs_call_atm"
  )

def test_delta_atm() -> unit ! { Test } =
  assert_close(
    delta(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.20, f32), cast(1.0, f32)),
    cast(0.6368, f32),
    cast(0.01, f32),
    "bs_delta_atm"
  )

def test_vega_positive() -> unit ! { Test } =
  assert_close(
    vega(cast(100.0, f32), cast(100.0, f32), cast(0.05, f32), cast(0.20, f32), cast(1.0, f32)),
    cast(37.524, f32),
    cast(0.5, f32),
    "bs_vega_atm"
  )
