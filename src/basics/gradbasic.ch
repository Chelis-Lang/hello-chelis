module Hello.Basics.GradBasic
export (loss, dloss_dw, dloss_dx)
def loss(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[f32] = {
  err = sub(copy(w), to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)]))
  prod = mul(err, x)
  __borrow_migration_out_0 = sum(prod, 0)
  _ = drop(err)
  _ = drop(prod)
  __borrow_migration_out_0
}
def dloss_dw(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[n, f32] = grad(loss, wrt=w)(w, x)
def dloss_dx(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[n, f32] = grad(loss, wrt=x)(w, x)
