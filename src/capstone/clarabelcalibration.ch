module Hello.Capstone.ClarabelCalibration
import Clarabel.Qp (NonnegativeCone, Settings, Solved, solve)
import Shoals.Pricing (bs_call_f64)
export (calibrate_hedge, demo_calibration, quality)
-- A desk holds calls struck at 90, 100, 110, and 120. It wants a long-only
-- basket of those calls that tracks a liability struck at 103. These are
-- synthetic prices under one Black-Scholes model, not observed market quotes.
def scenario_prices(spot: f64) -> List[f64] = [bs_call_f64(spot, 90.0f64, 0.03f64, 0.25f64, 1.0f64), bs_call_f64(spot, 100.0f64, 0.03f64, 0.25f64, 1.0f64), bs_call_f64(spot, 110.0f64, 0.03f64, 0.25f64, 1.0f64), bs_call_f64(spot, 120.0f64, 0.03f64, 0.25f64, 1.0f64)]
def liability_price(spot: f64) -> f64 = bs_call_f64(spot, 103.0f64, 0.03f64, 0.25f64, 1.0f64)
-- Four scenario rows price the listed calls; four more rows penalize
-- concentrated positions. The resulting design matrix is 8 by 4.
def hedge_basis() -> tensor[8, 4, f64] = to_tensor([scenario_prices(85.0f64), scenario_prices(95.0f64), scenario_prices(105.0f64), scenario_prices(115.0f64), [0.2f64, 0.0f64, 0.0f64, 0.0f64], [0.0f64, 0.2f64, 0.0f64, 0.0f64], [0.0f64, 0.0f64, 0.2f64, 0.0f64], [0.0f64, 0.0f64, 0.0f64, 0.2f64]])
def liability_quotes() -> tensor[8, f64] = to_tensor([liability_price(85.0f64), liability_price(95.0f64), liability_price(105.0f64), liability_price(115.0f64), 0.0f64, 0.0f64, 0.0f64, 0.0f64])
-- QP objective: 1/2 z^T P z + q^T z, with P = B^T B and q = -B^T target.
-- Its difference from half the squared tracking error is constant in z.
-- This score is used by the running program and by the property file.
def quality(updated: tensor[4, f64], state: tensor[4, f64], p: tensor[4, 4, f64], q: tensor[4, f64]) -> f64 = {
  step = sub(updated, state)
  weighted = reshape(matmul(p, reshape(step, [4i64, 1i64])), [4i64])
  ((0.0f64 - (0.5f64 * tensor_to_scalar(sum(mul(step, weighted), 0i32)))) - tensor_to_scalar(sum(mul(q, step), 0i32)))
}
def tracking_loss(weights: tensor[4, f64], basis: tensor[8, 4, f64], target: tensor[8, f64]) -> f64 = {
  predicted = reshape(matmul(basis, reshape(weights, [4i64, 1i64])), [8i64])
  residual = sub(predicted, target)
  tensor_to_scalar(sum(mul(residual, residual), 0i32))
}
-- Solve a four-variable, five-inequality QP. The first four inequalities
-- require nonnegative call positions; the fifth caps total notional at one.
-- The equal-weight hedge is feasible, so its tracking loss is a useful
-- comparison for the solver's candidate. Runtime checks allow numerical error;
-- the separate property treats Solved as an exact-real optimizer by axiom.
def calibrate_hedge(basis: tensor[8, 4, f64], target: tensor[8, f64]) -> (tensor[4, f64], f64, f64, f64) = {
  p = matmul(permute(basis, 1i32, 0i32), basis)
  q = neg(reshape(matmul(permute(basis, 1i32, 0i32), reshape(target, [8i64, 1i64])), [4i64]))
  a = to_tensor([[-1.0f64, 0.0f64, 0.0f64, 0.0f64], [0.0f64, -1.0f64, 0.0f64, 0.0f64], [0.0f64, 0.0f64, -1.0f64, 0.0f64], [0.0f64, 0.0f64, 0.0f64, -1.0f64], [1.0f64, 1.0f64, 1.0f64, 1.0f64]])
  b = to_tensor([0.0f64, 0.0f64, 0.0f64, 0.0f64, 1.0f64])
  state = to_tensor([0.0f64, 0.0f64, 0.0f64, 0.0f64])
  baseline = to_tensor([0.25f64, 0.25f64, 0.25f64, 0.25f64])
  settings = Settings { max_iterations: 200i64, absolute_gap_tolerance: 1e-9f64, relative_gap_tolerance: 1e-9f64, feasibility_tolerance: 1e-9f64 }
  match solve(p, q, a, b, [NonnegativeCone(5i64)], settings) with {
    | Solved { primal, dual, slack, iterations, primal_residual, dual_residual } => {
    updated = add(state, primal)
    baseline_updated = add(state, baseline)
    score_gain = (quality(updated, state, p, q) - quality(baseline_updated, state, p, q))
    (updated, tracking_loss(updated, basis, target), tracking_loss(baseline, basis, target), score_gain)
  }
    | _ => fail("Clarabel did not solve the hedge QP")
  }
}
def demo_calibration() -> (tensor[4, f64], f64, f64, f64) = calibrate_hedge(hedge_basis(), liability_quotes())
