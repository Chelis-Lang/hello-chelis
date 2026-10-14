module Hello.Tests.Proofdemos.GrowthScreen
import Hello.Examples.Proofdemos.GrowthScreen (valuation, screened_value, purchase_margin)
import Std.Test (assert_close, assert_true)
def test_growth_scenario() -> unit ! { Test } = {
  _ = assert_close(valuation(1.0f32, 0.08f32, 0.03f32), 20.0f32, 0.001f32, "Gordon value")
  assert_close(purchase_margin(1.0f32, 0.08f32, 0.03f32, 18.0f32), 2.0f32, 0.001f32, "value less purchase price")
}
def test_screened_domain() -> unit ! { Test } = {
  accepted = match screened_value(1.0f32, 0.08f32, 0.03f32) with {
    | Some(v) => ((v >= 6.0f32) && (v <= 26.0f32))
    | None => false
  }
  rejected = match screened_value(1.0f32, 0.03f32, 0.08f32) with {
    | None => true
    | Some(_) => false
  }
  _ = assert_true(accepted, "inside the finite valuation box")
  assert_true(rejected, "reject a growth rate above required return")
}
