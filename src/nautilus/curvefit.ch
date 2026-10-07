module Hello.Nautilus.CurveFit
import Nautilus.CurveFit (lm_scalar_1param)
export (fit_exp_decay, fit_linear_through_origin)
def exp_decay_model(x: f32, theta: f32) -> f32 = exp(neg(mul(theta, x)))
def exp_decay_dmodel(x: f32, theta: f32) -> f32 = {
  e = exp(neg(mul(theta, x)))
  mul(neg(x), e)
}
def fit_exp_decay() -> f32 = {
  xs = to_tensor([0.0f32, 1.0f32, 2.0f32, 3.0f32])
  ys = to_tensor([1.0f32, 0.6065307f32, 0.3678794f32, 0.2231302f32])
  lm_scalar_1param(exp_decay_model, exp_decay_dmodel, xs, ys, 1.0f32, 0.01f32, 1e-6f32, 200i64)
}
def lin_model(x: f32, theta: f32) -> f32 = mul(theta, x)
def lin_dmodel(x: f32, theta: f32) -> f32 = x
def fit_linear_through_origin() -> f32 = {
  xs = to_tensor([1.0f32, 2.0f32, 3.0f32, 4.0f32])
  ys = to_tensor([2.0f32, 4.0f32, 6.0f32, 8.0f32])
  lm_scalar_1param(lin_model, lin_dmodel, xs, ys, 0.5f32, 0.01f32, 1e-8f32, 100i64)
}
