module Hello.Tests.Nautilus.Stats
import Hello.Nautilus.Stats (sample_mean, sample_var, sample_std, sample_median, sample_correlation)
import Std.Test (assert_close)
def test_sample_mean_constant() -> unit ! { Test } = {
  v = to_tensor([2.0f32, 2.0f32, 2.0f32, 2.0f32])
  assert_close(sample_mean(v), 2.0f32, 1e-6f32, "mean of constant vec = constant")
}
def test_sample_var_constant_zero() -> unit ! { Test } = {
  v = to_tensor([5.0f32, 5.0f32, 5.0f32, 5.0f32])
  assert_close(sample_var(v), 0.0f32, 1e-6f32, "variance of constant = 0")
}
def test_sample_std_known() -> unit ! { Test } = {
  v = to_tensor([1.0f32, 2.0f32, 3.0f32, 4.0f32, 5.0f32])
  assert_close(sample_std(v), 1.5811388f32, 0.0001f32, "std [1..5] = sqrt(2.5)")
}
def test_sample_median_odd() -> unit ! { Test } = {
  v = to_tensor([3.0f32, 1.0f32, 2.0f32, 5.0f32, 4.0f32])
  assert_close(sample_median(v), 3.0f32, 1e-6f32, "median of 1..5 = 3")
}
def test_sample_correlation_perfect() -> unit ! { Test } = {
  a = to_tensor([1.0f32, 2.0f32, 3.0f32, 4.0f32])
  b = to_tensor([3.0f32, 5.0f32, 7.0f32, 9.0f32])
  assert_close(sample_correlation(a, b), 1.0f32, 0.0001f32, "perfect linear correlation = 1")
}
