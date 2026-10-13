module Hello.Basics.QuadraticDescent
export (quadratic, quadratic_gradient, gradient_step)
def quadratic(x: f32) -> f32 = {
  d = sub(x, 3.0f32)
  add(mul(d, d), 7.0f32)
}
def quadratic_gradient(x: f32) -> f32 = grad(quadratic, wrt=x)(x)
def gradient_step(x: f32, eta: f32) -> f32 = sub(x, mul(eta, quadratic_gradient(x)))
@property gradient_step_descends forall(x: f32, eta: f32) where eta >= 0.0f32, eta <= 1.0f32:
  (quadratic(gradient_step(x, eta)) <= quadratic(x))
@property half_step_reaches_minimum forall(x: f32):
  (quadratic(gradient_step(x, 0.5f32)) == 7.0f32)
