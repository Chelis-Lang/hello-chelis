module Hello.Basics.GradBasic


export (loss, dloss_dw, dloss_dx)

-- A simple scalar loss: sum of element-wise products of (w-1) and x.
-- The intermediate err = w - 1 is differentiable; sum reduces to a
-- scalar so the whole thing is grad-eligible.
def loss(w: tensor[3, f32], x: tensor[3, f32]) -> f32 = {
  err = sub(copy(w), to_tensor([cast(1.0, f32), cast(1.0, f32), cast(1.0, f32)]))
  prod = mul(err, x)
  tensor_to_scalar(sum(prod, 0))
}

-- d/dw [ sum((w - 1) * x) ] = x.
-- Lowering-friendly grad form: pass the scalar fn as a parameter, name
-- a local closure, call grad(local, wrt=(arg))(arg). The C backend
-- needs this shape; the inline `grad(f, wrt=w)(w, x)` form doesn't lower.
def dloss_dw(
  model: tensor[3, f32] -> tensor[3, f32] -> f32,
  w: tensor[3, f32],
  x: tensor[3, f32]
) -> tensor[3, f32] = {
  target = fn (w_local: tensor[3, f32]) -> model(w_local, x)
  grad(target, wrt=(w_local))(w)
}

-- d/dx [ sum((w - 1) * x) ] = w - 1.
def dloss_dx(
  model: tensor[3, f32] -> tensor[3, f32] -> f32,
  w: tensor[3, f32],
  x: tensor[3, f32]
) -> tensor[3, f32] = {
  target = fn (x_local: tensor[3, f32]) -> model(w, x_local)
  grad(target, wrt=(x_local))(x)
}
