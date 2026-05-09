module Hello.Tests.Nautilus.Hypothesis
import Hello.Nautilus.Hypothesis (z_score_at_mean, z_p_two_sided_zero, t_one_sample_at_mean, z_score)
import Std.Test (assert_close)
def test_z_score_at_mean_zero() -> unit ! { Test } = assert_close(z_score_at_mean(), cast(0.0, f32), cast(0.000001, f32), "z = 0 when sample_mean = pop_mean")
def test_z_p_two_sided_at_zero() -> unit ! { Test } = assert_close(z_p_two_sided_zero(), cast(1.0, f32), cast(0.00001, f32), "two-sided p(z=0) = 1")
def test_t_one_sample_at_mean_zero() -> unit ! { Test } = assert_close(t_one_sample_at_mean(), cast(0.0, f32), cast(0.000001, f32), "t = 0 when sample_mean = pop_mean")
def test_z_score_one_sigma() -> unit ! { Test } = assert_close(z_score(cast(51.0, f32), cast(50.0, f32), cast(10.0, f32), cast(100.0, f32)), cast(1.0, f32), cast(0.00001, f32), "z-score = 1 at one SE above mean")
