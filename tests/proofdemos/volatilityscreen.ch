module Hello.Tests.Proofdemos.VolatilityScreen
import Hello.Examples.Proofdemos.VolatilityScreen (total_variance, screened_variance, implied_volatility)
import Std.Test (assert_close, assert_true)
def test_svi_slice() -> unit ! { Test } = {
  _ = assert_close(total_variance(0.01f32, 0.1f32, 0.0f32, 0.0f32, 0.2f32, 0.0f32), 0.03f32, 0.00001f32, "ATM variance")
  assert_close(implied_volatility(0.01f32, 0.1f32, 0.0f32, 0.0f32, 0.2f32, 0.0f32, 1.0f32), 0.173205f32, 0.0001f32, "one-year implied volatility")
}
def test_reject_negative_minimum_and_bad_rho() -> unit ! { Test } = {
  negative = match screened_variance(-1.0f32, 0.0f32, 0.0f32, 0.0f32, 0.2f32, 0.0f32) with {
    | None => true
    | Some(_) => false
  }
  bad_rho = match screened_variance(0.01f32, 0.1f32, 2.0f32, 0.0f32, 0.2f32, 0.0f32) with {
    | None => true
    | Some(_) => false
  }
  _ = assert_true(negative, "minimum-variance condition matters")
  assert_true(bad_rho, "reject rho before taking sqrt(1-rho^2)")
}
def test_accept_nonnegative_fit() -> unit ! { Test } = {
  admitted = match screened_variance(0.01f32, 0.1f32, 0.0f32, 0.0f32, 0.2f32, 0.0f32) with {
    | Some(v) => ((v >= 0.02999f32) && (v <= 0.03001f32))
    | None => false
  }
  assert_true(admitted, "accept a fitted slice with a positive minimum")
}
