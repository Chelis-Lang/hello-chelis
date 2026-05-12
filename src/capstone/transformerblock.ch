module Hello.Capstone.TransformerBlock
export (block)
def block(x: tensor[seq, 256, f32], wq: tensor[256, 64, f32], wk: tensor[256, 64, f32], wv: tensor[256, 64, f32], wo: tensor[64, 256, f32], ff1: tensor[256, 1024, f32], ff2: tensor[1024, 256, f32]) -> tensor[seq, 256, f32] = {
  q = matmul(x, wq)
  k = matmul(x, wk)
  v = matmul(x, wv)
  scores = matmul(q, permute(k, 1, 0))
  probs = softmax(scores, 1)
  attn_out = probs |> matmul(v) |> matmul(wo)
  resid1 = add(x, attn_out)
  ff_out = matmul(matmul(resid1, ff1), ff2)
  add(resid1, ff_out)
}
