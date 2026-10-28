module Hello.Examples.Proofdemos.VolatilityScreen
-- Run from the hello-chelis repository root:
-- chelis eval --file examples/proofdemos/volatilityscreen.ch
-- Prove the guarded mathematical claims:
-- chelis prove examples/proofdemos/volatilityscreen.ch --tier smt-only --only smt_ --json
-- The counterexample_* claims below are deliberately false. Select them
-- with --tier smt-only --only counterexample_symbolic_; refutation exits 1.
import Shoals.VolSurface (SVI, vs_total_variance)
export (total_variance, screened_variance, implied_volatility, volatility_report)
-- An SVI slice describes total variance versus log-strike k. Check a fitted
-- parameter set before using its variance inside a square root for a quote.
-- Gatheral/Jacquier's minimum condition below applies at every k and m; it
-- certifies variance nonnegativity, not full absence of static arbitrage.
def total_variance(a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32) -> f32 = vs_total_variance(SVI { a, b, rho, m, sigma }, k)
-- Test the square root's domain first. A Boolean expression which merely
-- mentions all the guards is not a substitute for this evaluation order.
def screened_variance(a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32) -> Option[f32] =
  if ((((b >= 0.0f32) && (rho > -1.0f32)) && (rho < 1.0f32)) && (sigma > 0.0f32)) then {
    minimum = (a + ((b * sigma) * sqrt((1.0f32 - (rho * rho)))))
    if (minimum >= 0.0f32) then Some(total_variance(a, b, rho, m, sigma, k)) else None
  } else None
-- The caller supplies positive maturity and an admitted parameter set.
-- The theorem below covers variance; it does not bound sqrt rounding or
-- guarantee that arbitrary external k/m values are finite machine numbers.
def implied_volatility(a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32, maturity: f32) -> f32 = sqrt((total_variance(a, b, rho, m, sigma, k) / maturity))
def volatility_report() -> (f32, f32, f32) = (implied_volatility(0.01f32, 0.1f32, -0.2f32, 0.0f32, 0.2f32, -0.1f32, 1.0f32), implied_volatility(0.01f32, 0.1f32, -0.2f32, 0.0f32, 0.2f32, 0.0f32, 1.0f32), implied_volatility(0.01f32, 0.1f32, -0.2f32, 0.0f32, 0.2f32, 0.1f32, 1.0f32))
-- State the theorem at the imported API boundary, with the same record that
-- total_variance constructs. The released SMT lane supports this direct
-- record call; the extra local record-building wrapper does not lower there.
@property smt_svi_variance_nonnegative forall(a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32) where b >= 0.0f32, rho > -1.0f32, rho < 1.0f32, sigma > 0.0f32, (a + ((b * sigma) * sqrt((1.0f32 - (rho * rho))))) >= 0.0f32:
  (vs_total_variance(SVI { a, b, rho, m, sigma }, k) >= 0.0f32)
-- Concrete report: these top-level bindings are printed by chelis eval.
-- Quote an SVI slice at three log-strikes after choosing admissible parameters.
-- A fitted slice with a negative minimum is rejected by the screening API.
slice_volatilities = volatility_report()
negative_variance_fit = screened_variance(-1.0f32, 0.0f32, 0.0f32, 0.0f32, 0.2f32, 0.0f32)
-- Deliberately false claims: inspect the assumptions they omit or reverse.
@property counterexample_symbolic_svi_without_minimum forall(a: f32, b: f32, rho: f32, m: f32, sigma: f32, k: f32) where b >= 0.0f32, rho > -1.0f32, rho < 1.0f32, sigma > 0.0f32:
  (vs_total_variance(SVI { a, b, rho, m, sigma }, k) >= 0.0f32)
