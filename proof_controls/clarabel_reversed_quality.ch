module Hello.Proof_controls.Clarabel_reversed_quality
import Clarabel.Qp (NonnegativeCone, Settings, Solved, solve)
import Hello.Capstone.ClarabelCalibration (quality)
-- Reversing the comparison must not inherit the solver axiom as a free pass.
@property reversed_quality_must_not_prove forall(basis: tensor[8, 4, f64], q: tensor[4, f64], state: tensor[4, f64]):
  match solve(matmul(permute(basis, 1i32, 0i32), basis), q, to_tensor([[-1.0f64, 0.0f64, 0.0f64, 0.0f64], [0.0f64, -1.0f64, 0.0f64, 0.0f64], [0.0f64, 0.0f64, -1.0f64, 0.0f64], [0.0f64, 0.0f64, 0.0f64, -1.0f64], [1.0f64, 1.0f64, 1.0f64, 1.0f64]]), to_tensor([0.0f64, 0.0f64, 0.0f64, 0.0f64, 1.0f64]), [NonnegativeCone(5i64)], Settings { max_iterations: 200i64, absolute_gap_tolerance: 1e-9f64, relative_gap_tolerance: 1e-9f64, feasibility_tolerance: 1e-9f64 }) with {
    | Solved { primal, dual, slack, iterations, primal_residual, dual_residual } => (quality(add(state, primal), state, matmul(permute(basis, 1i32, 0i32), basis), q) <= quality(add(state, to_tensor([0.25f64, 0.25f64, 0.25f64, 0.25f64])), state, matmul(permute(basis, 1i32, 0i32), basis), q))
    | _ => true
  }
  with contract = "clarabel.qp.ideal_optimality"
