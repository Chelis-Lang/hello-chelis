module Hello.Proof_controls.Proofdemos_wrong
import Hello.Proofdemos.ProbabilityBudget (uniform_payout)
import Hello.Proofdemos.CurveBudget (spend_from_weight)
import Hello.Proofdemos.CollateralBudget (bond_mark, unsecured_exposure)
import Hello.Proofdemos.GrowthScreen (valuation)
import Hello.Proofdemos.OptionRisk (hedge_from_delta, notional_from_vega)
import Shoals.VolSurface (SVI, vs_total_variance)
-- These intentionally false claims are teaching counterexamples. Run this
-- file separately: a correct solver returns failed and a witness, exit 1.
@property smt_payout_half_budget_wrong forall(x: f32) where x >= 0.0f32, x <= 10.0f32:
  (uniform_payout(x, 0.0f32, 10.0f32, 1000.0f32) <= 500.0f32)
@property smt_spend_without_weight_guard_wrong forall(weight: f32):
  (spend_from_weight(weight) <= 750.0f32)
@property smt_coupon_reverse_wrong forall(c1: f32, c2: f32, y: f32) where c1 >= 0.0f32, c2 > c1, y >= 0.0f32:
  (bond_mark(c2, y) <= bond_mark(c1, y))
@property smt_haircut_reverse_wrong forall(h: f32) where h > 0.0f32, h <= 1.0f32:
  (unsecured_exposure(1000.0f32, h) < unsecured_exposure(1000.0f32, 0.0f32))
@property smt_growth_without_order_wrong forall(g1: f32, g2: f32) where g1 >= 0.02f32, g1 <= 0.04f32, g2 >= 0.02f32, g2 <= 0.04f32:
  (valuation(1.0f32, 0.1f32, g2) > valuation(1.0f32, 0.1f32, g1))
@property smt_hedge_half_position_wrong forall(d: f32) where d >= 0.0f32, d <= 1.0f32:
  (hedge_from_delta(d) <= 5.0f32)
@property smt_vega_tight_budget_wrong forall(v: f32) where v >= 0.0f32, v <= 42.0f32:
  (notional_from_vega(v) <= 400.0f32)
@property smt_svi_without_minimum_wrong forall(a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32) where b >= 0.0f32, rho > -1.0f32, rho < 1.0f32, sigma > 0.0f32:
  (vs_total_variance(SVI { a, b, rho, m, sigma }, k) >= 0.0f32)
