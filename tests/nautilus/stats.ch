module Hello.Tests.Nautilus.Stats

import Hello.Nautilus.Stats (sample_mean, sample_var, sample_std, sample_median, sample_correlation)
import Std.Test (assert_close)

def test_sample_mean_constant() -> unit ! { Test } = {
  v = to_tensor([cast(2.0, f32), cast(2.0, f32), cast(2.0, f32), cast(2.0, f32)])
  assert_close(sample_mean(v), cast(2.0, f32), cast(1.0e-6, f32), "mean of constant vec = constant")
}

def test_sample_var_constant_zero() -> unit ! { Test } = {
  v = to_tensor([cast(5.0, f32), cast(5.0, f32), cast(5.0, f32), cast(5.0, f32)])
  assert_close(sample_var(v), cast(0.0, f32), cast(1.0e-6, f32), "variance of constant = 0")
}

def test_sample_std_known() -> unit ! { Test } = {
  -- [1,2,3,4,5]: mean=3, sum sq diff = 4+1+0+1+4 = 10, ddof=1 -> var = 10/4 = 2.5, std = sqrt(2.5) ~ 1.5811
  v = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])
  assert_close(sample_std(v), cast(1.5811388, f32), cast(1.0e-4, f32), "std [1..5] = sqrt(2.5)")
}

def test_sample_median_odd() -> unit ! { Test } = {
  v = to_tensor([cast(3.0, f32), cast(1.0, f32), cast(2.0, f32), cast(5.0, f32), cast(4.0, f32)])
  assert_close(sample_median(v), cast(3.0, f32), cast(1.0e-6, f32), "median of 1..5 = 3")
}

def test_sample_correlation_perfect() -> unit ! { Test } = {
  -- y = 2x + 1 -> correlation = 1
  a = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32)])
  b = to_tensor([cast(3.0, f32), cast(5.0, f32), cast(7.0, f32), cast(9.0, f32)])
  assert_close(sample_correlation(a, b), cast(1.0, f32), cast(1.0e-4, f32), "perfect linear correlation = 1")
}
