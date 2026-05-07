module Hello.Nautilus.HypothesisTests

import Std.Tensor.Construct (to_tensor)
import Nautilus.Hypothesis (z_test_one_sample, t_test_one_sample, chi_squared_gof)
import Std.Test (assert_close, assert_true)

def sample() -> tensor[n, f32] =
  to_tensor([4.9, 5.1, 4.95, 5.05, 5.0, 4.98, 5.02, 5.0])

// One-sample tests against H0: mean = 5.0. The p-value should be high
// (not significant) for data centered around 5.0.

def test_z_test_high_p() -> unit ! { Test } = {
  result = z_test_one_sample(sample(), cast(5.0, f32), cast(0.05, f32))
  // The p-value field is part of the result tuple/record. We assert
  // we don't reject H0 (i.e. p > 0.05).
  assert_true(p_value(result) > cast(0.05, f32), "z_test_pvalue")
}

def test_t_test_high_p() -> unit ! { Test } = {
  result = t_test_one_sample(sample(), cast(5.0, f32))
  assert_true(p_value_t(result) > cast(0.05, f32), "t_test_pvalue")
}

// Each Nautilus.Hypothesis result type exports a field accessor; we name
// the helpers explicitly here for readability.
def p_value(r: ZTestResult) -> tensor[f32] =
  match r with { | ZTestResult { p_value } => p_value }

def p_value_t(r: TTestResult) -> tensor[f32] =
  match r with { | TTestResult { p_value } => p_value }
