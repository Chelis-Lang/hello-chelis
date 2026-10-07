module GradQuadratic
def sumsq(theta: tensor[3, f32]) -> f32 = tensor_to_scalar(sum(mul(theta, theta), 0))
def grad_sumsq(model: tensor[3, f32] -> f32, theta: tensor[3, f32]) -> tensor[3, f32] = {
  target = fn (theta_local: tensor[3, f32]) -> model(theta_local)
  grad(target, wrt=theta_local)(theta)
}
theta = to_tensor([1.0f32, 2.0f32, 3.0f32])
dsumsq = grad_sumsq(sumsq, theta)
