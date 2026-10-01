module Hello.Basics.GradBasic
export (loss, dloss_dw, dloss_dx)
def loss(w: tensor[3, f32], x: tensor[3, f32]) -> tensor[f32] = {
  err = sub(w, to_tensor([1.0f32, 1.0f32, 1.0f32]))
  prod = mul(err, x)
  sum(prod, 0)
}
def dloss_dw(w: tensor[3, f32], x: tensor[3, f32]) -> tensor[3, f32] = grad(loss, wrt=w)(w, x)
def dloss_dx(w: tensor[3, f32], x: tensor[3, f32]) -> tensor[3, f32] = grad(loss, wrt=x)(w, x)
