module GradWorks
def loss_fn(w: tensor[3, f32], x: tensor[3, f32]) -> f32 = {
  one_vec = to_tensor([1.0f32, 1.0f32, 1.0f32])
  err = sub(w, one_vec)
  prod = mul(err, x)
  prod |> sum(0) |> tensor_to_scalar
}
def dloss_dw(model: tensor[3, f32] -> tensor[3, f32] -> f32, w: tensor[3, f32], x: tensor[3, f32]) -> tensor[3, f32] = {
  target = fn (w_local: tensor[3, f32]) -> model(w_local, x)
  grad(target, wrt=w_local)(w)
}
w0 = to_tensor([0.5f32, 0.5f32, 0.5f32])
x0 = to_tensor([1.0f32, 2.0f32, 3.0f32])
dw = dloss_dw(loss_fn, w0, x0)
