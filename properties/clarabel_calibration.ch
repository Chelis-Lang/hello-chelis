module Hello.Properties.Clarabel_calibration
import Clarabel.Qp (NonnegativeCone, Settings, Solved, solve)
import Hello.Capstone.ClarabelCalibration (quality)
-- The matrix below encodes four long-only positions and a unit budget.
-- The equal-weight comparison is feasible for exactly these constraints.
def interior(step: tensor[4, f64]) -> bool = {
  first = tensor_to_scalar(sum(mul(step, to_tensor([1.0f64, 0.0f64, 0.0f64, 0.0f64])), 0i32))
  second = tensor_to_scalar(sum(mul(step, to_tensor([0.0f64, 1.0f64, 0.0f64, 0.0f64])), 0i32))
  third = tensor_to_scalar(sum(mul(step, to_tensor([0.0f64, 0.0f64, 1.0f64, 0.0f64])), 0i32))
  fourth = tensor_to_scalar(sum(mul(step, to_tensor([0.0f64, 0.0f64, 0.0f64, 1.0f64])), 0i32))
  and((first > 0.0f64), and((second > 0.0f64), and((third > 0.0f64), and((fourth > 0.0f64), (tensor_to_scalar(sum(step, 0i32)) < 1.0f64)))))
}
def gradient_zero(p: tensor[4, 4, f64], q: tensor[4, f64], step: tensor[4, f64]) -> bool = {
  gradient = add(reshape(matmul(p, reshape(step, [4i64, 1i64])), [4i64]), q)
  first = tensor_to_scalar(sum(mul(gradient, to_tensor([1.0f64, 0.0f64, 0.0f64, 0.0f64])), 0i32))
  second = tensor_to_scalar(sum(mul(gradient, to_tensor([0.0f64, 1.0f64, 0.0f64, 0.0f64])), 0i32))
  third = tensor_to_scalar(sum(mul(gradient, to_tensor([0.0f64, 0.0f64, 1.0f64, 0.0f64])), 0i32))
  fourth = tensor_to_scalar(sum(mul(gradient, to_tensor([0.0f64, 0.0f64, 0.0f64, 1.0f64])), 0i32))
  and((first == 0.0f64), and((second == 0.0f64), and((third == 0.0f64), (fourth == 0.0f64))))
}
-- This property does not ask SMT to trust a spelled contract name alone: the
-- axiom is bound to this resolved Clarabel.solve call and its P, q, A, b.
-- P = B^T B is positive semidefinite for every real B. For every B and q,
-- an ideal Solved step therefore beats the feasible equal-weight hedge.
@property optimized_step_beats_baseline forall(basis: tensor[8, 4, f64], q: tensor[4, f64], state: tensor[4, f64]):
  match solve(matmul(permute(basis, 1i32, 0i32), basis), q, to_tensor([[-1.0f64, 0.0f64, 0.0f64, 0.0f64], [0.0f64, -1.0f64, 0.0f64, 0.0f64], [0.0f64, 0.0f64, -1.0f64, 0.0f64], [0.0f64, 0.0f64, 0.0f64, -1.0f64], [1.0f64, 1.0f64, 1.0f64, 1.0f64]]), to_tensor([0.0f64, 0.0f64, 0.0f64, 0.0f64, 1.0f64]), [NonnegativeCone(5i64)], Settings { max_iterations: 200i64, absolute_gap_tolerance: 1e-9f64, relative_gap_tolerance: 1e-9f64, feasibility_tolerance: 1e-9f64 }) with {
    | Solved { primal, dual, slack, iterations, primal_residual, dual_residual } => (quality(add(state, primal), state, matmul(permute(basis, 1i32, 0i32), basis), q) >= quality(add(state, to_tensor([0.25f64, 0.25f64, 0.25f64, 0.25f64])), state, matmul(permute(basis, 1i32, 0i32), basis), q))
    | _ => true
  }
  with contract = "clarabel.qp.ideal_optimality"
-- At a strictly interior optimum, no inequality blocks a small move in a
-- downhill direction, so P*x + q must vanish. This says nothing about a
-- boundary solution, where a nonzero gradient may be balanced by constraints.
@property interior_hedge_is_stationary forall(basis: tensor[8, 4, f64], q: tensor[4, f64]):
  match solve(matmul(permute(basis, 1i32, 0i32), basis), q, to_tensor([[-1.0f64, 0.0f64, 0.0f64, 0.0f64], [0.0f64, -1.0f64, 0.0f64, 0.0f64], [0.0f64, 0.0f64, -1.0f64, 0.0f64], [0.0f64, 0.0f64, 0.0f64, -1.0f64], [1.0f64, 1.0f64, 1.0f64, 1.0f64]]), to_tensor([0.0f64, 0.0f64, 0.0f64, 0.0f64, 1.0f64]), [NonnegativeCone(5i64)], Settings { max_iterations: 200i64, absolute_gap_tolerance: 1e-9f64, relative_gap_tolerance: 1e-9f64, feasibility_tolerance: 1e-9f64 }) with {
    | Solved { primal, dual, slack, iterations, primal_residual, dual_residual } => if interior(primal) then gradient_zero(matmul(permute(basis, 1i32, 0i32), basis), q, primal) else true
    | _ => true
  }
  with contract = "clarabel.qp.ideal_optimality"
