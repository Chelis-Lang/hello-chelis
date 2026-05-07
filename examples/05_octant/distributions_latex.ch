module Hello.Octant.DistributionsLatex

// Verified output of `octant translate distributions_latex.tex`.

import Nautilus.Distributions.Normal as N
import Nautilus.Special (erf)

// span: distributions_latex.tex#eq:bs_cdf_001
def n_d1(d1: f32) -> f32 =
  N.cdf(d1, cast(0.0, f32), cast(1.0, f32))

// span: distributions_latex.tex#eq:phi_001
def big_phi(x: f32) -> f32 =
  N.cdf(x, cast(0.0, f32), cast(1.0, f32))

// span: distributions_latex.tex#eq:phi_lower_001
def small_phi(x: f32) -> f32 =
  N.pdf(x, cast(0.0, f32), cast(1.0, f32))

// span: distributions_latex.tex#eq:erf_001
def erf_x(x: f32) -> f32 = erf(x)
