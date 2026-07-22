module GradQuadratic
def sumsq(theta: tensor[3, f32]) -> f32 = tensor_to_scalar(sum(mul(theta, theta), 0))
theta = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
dsumsq = grad(sumsq, wrt=theta)(theta)
