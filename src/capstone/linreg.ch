module Hello.Capstone.LinReg
export (predict, mse_loss, sgd_step)
def predict(x: tensor[64, 64, f32], w: tensor[64, 1, f32], b: tensor[1, f32]) -> tensor[64, 1, f32] = x |> matmul(w) |> add(expand(b, 0, 64))
def mse_loss(x: tensor[64, 64, f32], y: tensor[64, 1, f32], w: tensor[64, 1, f32], b: tensor[1, f32]) -> tensor[f32] = {
  pred = predict(x, w, b)
  err = sub(pred, y)
  err_copy = err
  sum(sum(mul(err, err_copy), 1), 0)
}
def sgd_step(x: tensor[64, 64, f32], y: tensor[64, 1, f32], w: tensor[64, 1, f32], b: tensor[1, f32], lr: f32) -> (tensor[64, 1, f32], tensor[1, f32]) = {
  dw = grad(mse_loss, wrt=w)(x, y, w, b)
  db = grad(mse_loss, wrt=b)(x, y, w, b)
  lr_t = to_tensor([lr])
  new_w = sub(w, mul(expand(expand(lr_t, 0, 64), 1, 1), dw))
  new_b = sub(b, mul(lr_t, db))
  (new_w, new_b)
}
