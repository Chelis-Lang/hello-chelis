module GradWorks
def loss_fn[n](w: tensor[n, f32], x: tensor[n, f32]) -> f32 = {
  one_vec = to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)])
  err = sub(w, one_vec)
  prod = mul(err, x)
  __borrow_migration_out_0 = tensor_to_scalar(sum(prod, 0))
  __borrow_migration_out_0
}
def dloss_dw[n](model: tensor[n, f32] -> tensor[n, f32] -> f32, w: tensor[n, f32], x: tensor[n, f32]) -> tensor[n, f32] = {
  target = fn (w_local: tensor[n, f32]) -> model(w_local, x)
  grad(target, wrt=w_local)(w)
}
w0 = to_tensor([cast(0.5, f32), cast(0.5, f32), cast(0.5, f32)])
x0 = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
dw = dloss_dw(loss_fn, w0, x0)
