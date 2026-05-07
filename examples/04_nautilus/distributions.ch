module Hello.Nautilus.Distributions

import Nautilus.Distributions.Normal as N
import Nautilus.Distributions.Poisson as Poisson
import Nautilus.Distributions.Beta as Beta
import Std.Test (assert_close)

def test_normal_pdf_at_zero() -> unit ! { Test } =
  // standard-normal pdf(0) = 1 / sqrt(2*pi) ~= 0.39894
  assert_close(N.pdf(cast(0.0, f32), cast(0.0, f32), cast(1.0, f32)), 0.39894, 1e-3, "normpdf_0")

def test_normal_cdf_at_zero() -> unit ! { Test } =
  assert_close(N.cdf(cast(0.0, f32), cast(0.0, f32), cast(1.0, f32)), 0.5, 1e-6, "normcdf_0")

def test_normal_inv_at_half() -> unit ! { Test } =
  assert_close(N.inv(cast(0.5, f32), cast(0.0, f32), cast(1.0, f32)), 0.0, 1e-3, "norminv_05")

def test_poisson_pmf_at_zero() -> unit ! { Test } =
  // P(X=0 | lambda=1) = exp(-1) ~= 0.3679
  assert_close(Poisson.pmf(cast(0, int64), cast(1.0, f32)), 0.3679, 1e-3, "pois_pmf_0")

def test_beta_pdf_uniform() -> unit ! { Test } =
  // Beta(1, 1) is the uniform distribution; pdf is identically 1.
  assert_close(Beta.pdf(cast(0.5, f32), cast(1.0, f32), cast(1.0, f32)), 1.0, 1e-6, "beta_uniform")
