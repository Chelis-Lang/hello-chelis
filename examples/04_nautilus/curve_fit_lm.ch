module Hello.Nautilus.CurveFitLm

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)
import Nautilus.CurveFit (lm_fit_1param)
import Std.Test (assert_close)

// Single-parameter exponential decay: y = exp(-a * x). Generate noiseless
// samples for a_true = 1.5, then fit and check we recover a_true.

def model(x: tensor[f32], a: tensor[f32]) -> tensor[f32] = exp(neg(mul(a, x)))

def fit_exponential() -> tensor[f32] = {
  xs = to_tensor([0.0, 0.5, 1.0, 1.5, 2.0])
  // y_true at a = 1.5
  ys = to_tensor([
    cast(1.0, f32),
    cast(0.4724, f32),
    cast(0.2231, f32),
    cast(0.1054, f32),
    cast(0.0498, f32)
  ])
  a0 = sum(to_tensor([1.0]), 0)  // initial guess = 1.0
  lm_fit_1param(model, xs, ys, a0, cast(1e-6, f32), cast(100, int64))
}

def test_lm_recovers_a() -> unit ! { Test } = {
  a_hat = fit_exponential()
  assert_close(a_hat, 1.5, 1e-3, "lm_recover_a_1p5")
}
