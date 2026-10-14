module Hello.Tests.Capstone.ClarabelCalibration
import Hello.Capstone.ClarabelCalibration (calibrate_hedge, demo_calibration)
import Std.Test (assert_true)
def test_constrained_option_hedge() -> unit ! { Test } = {
  report = demo_calibration()
  weights = to_list(report.0)
  _ = assert_true((index(weights, 0i64) >= -1e-6f64), "first position is long-only")
  _ = assert_true((index(weights, 1i64) >= -1e-6f64), "second position is long-only")
  _ = assert_true((index(weights, 2i64) >= -1e-6f64), "third position is long-only")
  _ = assert_true((index(weights, 3i64) >= -1e-6f64), "fourth position is long-only")
  _ = assert_true((tensor_to_scalar(sum(report.0, 0i32)) <= 1.000001f64), "total notional stays within the budget")
  _ = assert_true((report.1 <= (report.2 + 1e-6f64)), "the solved hedge has no larger least-squares loss than equal weights")
  assert_true((report.3 >= -1e-6f64), "the QP score also improves over equal weights")
}
-- A second data configuration has a strict interior optimum. It checks the
-- reusable entry point without Shoals prices and exercises a different
-- active-constraint pattern from the option hedge above.
def test_interior_calibration() -> unit ! { Test } = {
  basis = to_tensor([[1.0f64, 0.0f64, 0.0f64, 0.0f64], [0.0f64, 1.0f64, 0.0f64, 0.0f64], [0.0f64, 0.0f64, 1.0f64, 0.0f64], [0.0f64, 0.0f64, 0.0f64, 1.0f64], [0.2f64, 0.0f64, 0.0f64, 0.0f64], [0.0f64, 0.2f64, 0.0f64, 0.0f64], [0.0f64, 0.0f64, 0.2f64, 0.0f64], [0.0f64, 0.0f64, 0.0f64, 0.2f64]])
  target = to_tensor([0.4f64, 0.3f64, 0.2f64, 0.1f64, 0.0f64, 0.0f64, 0.0f64, 0.0f64])
  report = calibrate_hedge(basis, target)
  weights = to_list(report.0)
  _ = assert_true((abs((index(weights, 0i64) - 0.3846153846153846f64)) < 0.0001f64), "interior first weight")
  _ = assert_true((abs((index(weights, 3i64) - 0.09615384615384616f64)) < 0.0001f64), "interior fourth weight")
  _ = assert_true((tensor_to_scalar(sum(report.0, 0i32)) < 0.97f64), "interior solution leaves budget unused")
  assert_true((report.1 < report.2), "interior calibration beats equal weights")
}
