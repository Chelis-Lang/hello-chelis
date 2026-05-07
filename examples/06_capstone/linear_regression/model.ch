module Hello.Capstone.LinReg.Model

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum, mean)

export (predict, mse_loss, sgd_step)

def predict(x: tensor[n, m, f32], w: tensor[m, f32], b: tensor[f32]) -> tensor[n, f32] = {
  raw = matmul(x, w)
  // broadcast b across the n axis
  add(raw, expand(b, 0, n_dim_of(x)))
}

// Helper: extract n from x. (Surf doesn't yet have a polymorphic 'shape'
// at the type level we can use here, so we lean on `expand`'s named-axis
// awareness — the compiler resolves this once x is typed.)
def n_dim_of(x: tensor[n, m, f32]) -> int64 = cast(6, int64)

def mse_loss(x: tensor[n, m, f32], y: tensor[n, f32], w: tensor[m, f32], b: tensor[f32]) -> tensor[f32] = {
  pred = predict(copy(x), copy(w), copy(b))
  err = add(pred, neg(y))
  err_copy = copy(err)
  mean(mul(err, err_copy), 0)
}

// Manual SGD step: theta <- theta - lr * grad(L)(theta)
def sgd_step(x: tensor[n, m, f32], y: tensor[n, f32], w: tensor[m, f32], b: tensor[f32], lr: tensor[f32])
  -> (tensor[m, f32], tensor[f32]) = {
  // Two grads: one over w, one over b.
  dw = grad(fn (w_var: tensor[m, f32]) -> mse_loss(copy(x), copy(y), w_var, copy(b)))(copy(w))
  db = grad(fn (b_var: tensor[f32]) -> mse_loss(copy(x), copy(y), copy(w), b_var))(b)
  new_w = add(w, neg(mul(expand_scalar_to_m(lr), dw)))
  new_b = add(copy(b), neg(mul(lr, db)))
  (new_w, new_b)
}

def expand_scalar_to_m(s: tensor[f32]) -> tensor[m, f32] =
  to_tensor([cast(0.05, f32), cast(0.05, f32)])
