module Hello.Nautilus.CurveFit

import Nautilus.CurveFit (lm_scalar_1param)

export (fit_exp_decay, fit_linear_through_origin)

-- y = exp(-theta * x)
def exp_decay_model(x: f32, theta: f32) -> f32 =
  exp(neg(mul(theta, x)))

-- d/dtheta exp(-theta x) = -x * exp(-theta x)
def exp_decay_dmodel(x: f32, theta: f32) -> f32 = {
  e = exp(neg(mul(theta, x)))
  mul(neg(x), e)
}

-- Fit y = exp(-theta * x) to noiseless data with true theta = 0.5.
-- xs = [0, 1, 2, 3], ys = [1, e^-0.5, e^-1, e^-1.5].
def fit_exp_decay() -> f32 = {
  xs = to_tensor([cast(0.0, f32), cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  ys = to_tensor([cast(1.0, f32), cast(0.6065307, f32),
                  cast(0.3678794, f32), cast(0.2231302, f32)])
  lm_scalar_1param(exp_decay_model, exp_decay_dmodel, xs, ys,
                   cast(1.0, f32),       -- theta0
                   cast(0.01, f32),      -- lambda0
                   cast(1.0e-6, f32),    -- tol
                   cast(200, int64))     -- max_iters
}

-- y = theta * x (linear through origin).
def lin_model(x: f32, theta: f32) -> f32 = mul(theta, x)
def lin_dmodel(x: f32, theta: f32) -> f32 = x

-- Fit y = theta * x to ys = 2*xs.
def fit_linear_through_origin() -> f32 = {
  xs = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32)])
  ys = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32), cast(8.0, f32)])
  lm_scalar_1param(lin_model, lin_dmodel, xs, ys,
                   cast(0.5, f32),
                   cast(0.01, f32),
                   cast(1.0e-8, f32),
                   cast(100, int64))
}
