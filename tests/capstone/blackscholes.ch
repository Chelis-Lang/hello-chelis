module Hello.Tests.Capstone.BlackScholes
import Hello.Capstone.BlackScholes (call_price, delta, vega)
import Std.Test (assert_close, assert_true)
def test_call_atm() -> unit ! { Test } = assert_close(call_price(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 10.4506f32, 0.05f32, "bs_call_atm")
def test_delta_atm() -> unit ! { Test } = assert_close(delta(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 0.63683f32, 0.001f32, "bs_delta_atm")
def test_vega_atm() -> unit ! { Test } = assert_close(vega(100.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32), 37.524f32, 0.01f32, "bs_vega_atm")
def test_greek_bounds_at_96() -> unit ! { Test } = {
  d = delta(96.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
  v = vega(96.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
  _ = assert_true(and(gte(d, 0.0f32), lte(d, 1.0f32)), "delta at lower spot endpoint")
  assert_true(and(gte(v, 0.0f32), lte(v, 42.0f32)), "vega at lower spot endpoint")
}
def test_greek_bounds_at_104() -> unit ! { Test } = {
  d = delta(104.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
  v = vega(104.0f32, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
  _ = assert_true(and(gte(d, 0.0f32), lte(d, 1.0f32)), "delta at upper spot endpoint")
  assert_true(and(gte(v, 0.0f32), lte(v, 42.0f32)), "vega at upper spot endpoint")
}
