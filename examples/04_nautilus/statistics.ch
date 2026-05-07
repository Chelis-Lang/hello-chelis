module Hello.Nautilus.Statistics

import Std.Tensor.Construct (to_tensor)
import Nautilus.Stats (mean, variance, std, skew, kurt, median, quantile, corr)
import Std.Test (assert_close)

def sample() -> tensor[n, f32] =
  to_tensor([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0])

def test_mean() -> unit ! { Test } =
  assert_close(mean(sample()), 5.5, 1e-6, "mean_1_10")

def test_variance() -> unit ! { Test } =
  // sample var (ddof=1) of 1..10 = 9.166...
  assert_close(variance(sample()), 9.16667, 1e-3, "var_1_10")

def test_median() -> unit ! { Test } =
  assert_close(median(sample()), 5.5, 1e-6, "median_1_10")

def test_quantile_p25() -> unit ! { Test } =
  // 25th percentile of 1..10 (linear interp) ~= 3.25
  assert_close(quantile(sample(), cast(0.25, f32)), 3.25, 1e-2, "q25")

def test_corr_self() -> unit ! { Test } = {
  // corr(x, x) = 1
  x = sample()
  y = copy(x)
  assert_close(corr(x, y), 1.0, 1e-6, "corr_self")
}
