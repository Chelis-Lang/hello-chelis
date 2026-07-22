module GradWorks
def loss_fn(w: tensor[3, f32], x: tensor[3, f32]) -> f32 = {
  one_vec = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
  err = sub(w, one_vec)
  prod = mul(err, x)
  prod |> sum(0) |> tensor_to_scalar
}
w0 = to_tensor([cast(0.5, f32), cast(0.5, f32), cast(0.5, f32)])
x0 = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
dw = grad(loss_fn, wrt=w)(w0, x0)
