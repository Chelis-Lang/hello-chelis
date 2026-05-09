module GradQuadratic
def sumsq(theta: tensor[3, f32]) -> f32 = tensor_to_scalar(sum(mul(copy(theta), theta), 0))
def grad_sumsq(model: tensor[3, f32] -> f32, theta: tensor[3, f32]) -> tensor[3, f32] = {
  target = fn (theta_local: tensor[3, f32]) -> model(theta_local)
  grad(target, wrt=theta_local)(theta)
}
theta = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
dsumsq = grad_sumsq(sumsq, theta)
