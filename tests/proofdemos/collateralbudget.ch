module Hello.Tests.Proofdemos.CollateralBudget
import Hello.Examples.Proofdemos.CollateralBudget (bond_mark, unsecured_exposure, capital_buffer)
import Std.Test (assert_close, assert_true)
def test_bond_coupon_scenario() -> unit ! { Test } = assert_true((bond_mark(0.06f32, 0.05f32) > bond_mark(0.04f32, 0.05f32)), "higher coupon raises the mark")
def test_collateral_budget() -> unit ! { Test } = {
  residual = unsecured_exposure(1000.0f32, 0.0f32)
  _ = assert_true(((residual >= 0.0f32) && (residual <= 1000.0f32)), "residual is within the original exposure")
  _ = assert_true((unsecured_exposure(1000.0f32, 0.5f32) >= residual), "a haircut reduces recognized collateral")
  _ = assert_close(unsecured_exposure(-100.0f32, 0.2f32), 0.0f32, 0.001f32, "negative exposure needs no reserve")
  assert_close(capital_buffer(1000.0f32, 1.0f32), 118.75f32, 0.001f32, "full haircut still subtracts the independent amount")
}
