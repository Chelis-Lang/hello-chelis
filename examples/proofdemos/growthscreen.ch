module Hello.Examples.Proofdemos.GrowthScreen
-- Run from the hello-chelis repository root:
-- chelis eval --file examples/proofdemos/growthscreen.ch
-- Prove the guarded mathematical claims:
-- chelis prove examples/proofdemos/growthscreen.ch --tier smt-only --only smt_ --json
-- The counterexample_* claims below are deliberately false. Select them
-- with --tier smt-only --only counterexample_symbolic_; refutation exits 1.
import Economoist.Growth (gordon_pv)
export (valuation, purchase_margin, screened_value, valuation_report)
-- Gordon's closed form values a next-period dividend with a positive discount
-- spread. This demo compares growth scenarios at the same required return.
-- The theorem concerns the formula; it does not prove that a dividend process
-- exists or that a company will realize the assumed perpetual growth.
def valuation(dividend: f32, required_return: f32, growth: f32) -> f32 = gordon_pv(dividend, required_return, growth)
def purchase_margin(dividend: f32, required_return: f32, growth: f32, market_price: f32) -> f32 = (valuation(dividend, required_return, growth) - market_price)
-- A finite input box keeps the denominator away from zero. It also tells a
-- caller which valuations the [6, 26] bounds below actually cover. Returning
-- None is a domain decision, not a statement that the asset is worthless.
def screened_value(d: f32, r: f32, g: f32) -> Option[f32] = if ((((((d >= 0.5f32) && (d <= 1.0f32)) && (r >= 0.08f32)) && (r <= 0.1f32)) && (g >= 0.02f32)) && (g <= 0.04f32)) then Some(valuation(d, r, g)) else None
def valuation_report() -> (f32, f32, f32) = (valuation(1.0f32, 0.08f32, 0.02f32), valuation(1.0f32, 0.08f32, 0.04f32), purchase_margin(1.0f32, 0.08f32, 0.03f32, 18.0f32))
@property smt_growth_raises_value forall(d: f32, r: f32, g1: f32, g2: f32) where d > 0.0f32, g2 > g1, r > g2:
  (valuation(d, r, g2) > valuation(d, r, g1))
@property smt_growth_raises_margin forall(d: f32, r: f32, g1: f32, g2: f32, price: f32) where d > 0.0f32, g2 > g1, r > g2:
  (purchase_margin(d, r, g2, price) > purchase_margin(d, r, g1, price))
@property smt_valuation_box_lower forall(d: f32, r: f32, g: f32) where d >= 0.5f32, d <= 1.0f32, r >= 0.08f32, r <= 0.1f32, g >= 0.02f32, g <= 0.04f32:
  (valuation(d, r, g) >= 6.0f32)
@property smt_valuation_box_upper forall(d: f32, r: f32, g: f32) where d >= 0.5f32, d <= 1.0f32, r >= 0.08f32, r <= 0.1f32, g >= 0.02f32, g <= 0.04f32:
  (valuation(d, r, g) <= 26.0f32)
-- Concrete report: these top-level bindings are printed by chelis eval.
-- Compare two growth scenarios and the value less an 18-unit market price.
growth_scenarios = valuation_report()
invalid_spread = screened_value(1.0f32, 0.03f32, 0.08f32)
-- Deliberately false claims: inspect the assumptions they omit or reverse.
@property counterexample_symbolic_growth_without_order forall(g1: f32, g2: f32) where g1 >= 0.02f32, g1 <= 0.04f32, g2 >= 0.02f32, g2 <= 0.04f32:
  (valuation(1.0f32, 0.1f32, g2) > valuation(1.0f32, 0.1f32, g1))
