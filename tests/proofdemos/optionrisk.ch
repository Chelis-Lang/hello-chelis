module Hello.Tests.Proofdemos.OptionRisk
import Hello.Examples.Proofdemos.OptionRisk (option_report, screened_report, report_delta, report_vega)
import Std.Test (assert_close, assert_true)
def test_option_report() -> unit ! { Test } = {
  (price, shares, vega_notional) = option_report(100.0f32)
  _ = assert_close(price, 10.4506f32, 0.05f32, "single call price")
  _ = assert_close(shares, 6.3683f32, 0.01f32, "delta hedge for ten calls")
  assert_close(vega_notional, 375.24f32, 0.1f32, "vega for ten calls per unit volatility")
}
def test_greek_endpoints_and_rejection() -> unit ! { Test } = {
  _ = assert_true(((report_delta(96.0f32) >= 0.0f32) && (report_delta(104.0f32) <= 1.0f32)), "sample the certified spot endpoints")
  _ = assert_true(((report_vega(96.0f32) >= 0.0f32) && (report_vega(104.0f32) <= 42.0f32)), "sample vega at the endpoints")
  rejected = match screened_report(120.0f32) with {
    | None => true
    | Some(_) => false
  }
  assert_true(rejected, "outside this report's certified spot box")
}
def test_accept_spot_box() -> unit ! { Test } = {
  admitted = match screened_report(100.0f32) with {
    | Some(_) => true
    | None => false
  }
  assert_true(admitted, "the report admits an in-box spot")
}
