module Hello.Examples.Proofdemos.ProbabilityBudget
-- Run from the hello-chelis repository root:
-- chelis eval --file examples/proofdemos/probabilitybudget.ch
-- Prove the guarded mathematical claims:
-- chelis prove examples/proofdemos/probabilitybudget.ch --tier smt-only --only smt_ --json
-- With CHELIS_BEACON_BIN set, certify the numerical bounds:
-- chelis prove examples/proofdemos/probabilitybudget.ch --tier beacon-only --only beacon_ --json
-- The counterexample_* claims below are deliberately false. Select them
-- with --tier smt-only --only counterexample_symbolic_, or
-- --tier beacon-only --only counterexample_interval_; refutation exits 1.
import Nautilus.Distributions (uniform_cdf, normal_cdf)
export (uniform_payout, normal_tail_reserve, probability_report)
-- A service pays a fixed amount when a measured delay exceeds a threshold.
-- The uniform model is useful when all we have is a bounded delay interval.
-- Multiplying the survival probability by a nonnegative payout turns a CDF
-- range theorem into a budget theorem: expectation cannot exceed the payout.
def uniform_payout(threshold: f32, lo: f32, hi: f32, payout: f32) -> f32 = {
  probability = (1.0f32 - uniform_cdf(threshold, lo, hi))
  (payout * probability)
}
-- A second model takes an already standardized threshold z. The amount 1000
-- is a maximum payout, not an estimate of the probability. This calls the
-- actual Nautilus CDF implementation; Beacon checks its graph on [-2, 2].
def normal_tail_reserve(z: f32) -> f32 = (1000.0f32 * (1.0f32 - normal_cdf(z, 0.0f32, 1.0f32)))
-- Compare three trigger levels. This is a model expectation, not a guarantee
-- that one realized payout or a collection of dependent events stays below it.
def probability_report() -> (f32, f32, f32) = (uniform_payout(2.0f32, 0.0f32, 10.0f32, 1000.0f32), uniform_payout(8.0f32, 0.0f32, 10.0f32, 1000.0f32), normal_tail_reserve(1.0f32))
-- SMT proves these for every threshold and every nonempty uniform interval.
-- The numerical claims in this directory interpret the source over the reals;
-- execution tests separately sample the rounded f32 calculations.
@property smt_uniform_payout_lower forall(threshold: f32, lo: f32, hi: f32, payout: f32) where hi > lo, payout >= 0.0f32:
  (uniform_payout(threshold, lo, hi, payout) >= 0.0f32)
@property smt_uniform_payout_upper forall(threshold: f32, lo: f32, hi: f32, payout: f32) where hi > lo, payout >= 0.0f32:
  (uniform_payout(threshold, lo, hi, payout) <= payout)
@property beacon_normal_reserve_lower forall(z: f32) where z >= -2.0f32, z <= 2.0f32:
  (normal_tail_reserve(z) >= 0.0f32)
@property beacon_normal_reserve_upper forall(z: f32) where z >= -2.0f32, z <= 2.0f32:
  (normal_tail_reserve(z) <= 1000.0f32)
-- Concrete report: these top-level bindings are printed by chelis eval.
-- A bounded delay model and a standardized normal model give different
-- payout expectations. Read the source's SMT and Beacon properties beside it.
payout_expectations = probability_report()
-- Deliberately false claims: inspect the assumptions they omit or reverse.
@property counterexample_symbolic_payout_half_budget forall(x: f32) where x >= 0.0f32, x <= 10.0f32:
  (uniform_payout(x, 0.0f32, 10.0f32, 1000.0f32) <= 500.0f32)
@property counterexample_interval_reserve_zero forall(z: f32) where z >= -2.0f32, z <= 2.0f32:
  (normal_tail_reserve(z) <= 0.0f32)
