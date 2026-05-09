module Hello.Nautilus.CurveFit
import Nautilus.CurveFit (lm_scalar_1param)
export (fit_exp_decay, fit_linear_through_origin)
def exp_decay_model(x: f32, theta: f32) -> f32 = exp(neg(mul(theta, x)))
def exp_decay_dmodel(x: f32, theta: f32) -> f32 = {
  e = exp(neg(mul(theta, x)))
  mul(neg(x), e)
}
def fit_exp_decay() -> f32 = {
  xs = to_tensor([cast(0.0, f32), cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  ys = to_tensor([cast(1.0, f32), cast(0.6065307, f32), cast(0.3678794, f32), cast(0.2231302, f32)])
  __borrow_migration_out_0 = lm_scalar_1param(exp_decay_model, exp_decay_dmodel, xs, ys, cast(1.0, f32), cast(0.01, f32), cast(0.000001, f32), cast(200, int64))
  _ = drop(xs)
  _ = drop(ys)
  __borrow_migration_out_0
}
def lin_model(x: f32, theta: f32) -> f32 = mul(theta, x)
def lin_dmodel(x: f32, theta: f32) -> f32 = x
def fit_linear_through_origin() -> f32 = {
  xs = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32)])
  ys = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32), cast(8.0, f32)])
  __borrow_migration_out_1 = lm_scalar_1param(lin_model, lin_dmodel, xs, ys, cast(0.5, f32), cast(0.01, f32), cast(0.00000001, f32), cast(100, int64))
  _ = drop(xs)
  _ = drop(ys)
  __borrow_migration_out_1
}
