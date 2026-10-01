module Hello.Tests.Capstone.BlackScholes
import Hello.Capstone.BlackScholes (call_price, delta, vega)
import Std.Test (assert_close)
def test_call_atm() -> unit ! { Test } = assert_close(call_price(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 10.4506f32, 0.05f32, "bs_call_atm")
def test_delta_atm() -> unit ! { Test } = assert_close(delta(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 0.63683f32, 0.001f32, "bs_delta_atm")
def test_vega_atm() -> unit ! { Test } = assert_close(vega(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 37.524f32, 0.01f32, "bs_vega_atm")
