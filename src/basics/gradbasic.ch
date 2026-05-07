module Hello.Basics.GradBasic


export (loss, dloss_dw, dloss_dx)

-- A simple scalar loss: sum of element-wise products of (w-1) and x.
-- The intermediate err = w - 1 is differentiable; sum reduces to a
-- scalar so the whole thing is grad-eligible.
def loss(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[f32] = {
  err = sub(copy(w), to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)]))
  prod = mul(err, x)
  sum(prod, 0)
}

-- `grad(loss, wrt=w)` returns d(loss)/dw at the call site.
-- d/dw [ sum((w - 1) * x) ] = x
def dloss_dw(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[n, f32] =
  grad(loss, wrt=w)(w, x)

-- d/dx [ sum((w - 1) * x) ] = w - 1
def dloss_dx(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[n, f32] =
  grad(loss, wrt=x)(w, x)
