module Hello.Capstone.Transformer.Block

import Std.Nn.Activation (relu, softmax)
import Std.Nn.Norm (layer_norm)

export (forward)

// Single-head transformer block. This is the primer's example, slightly
// simplified for size. Read it next to the primer's diagram.
//
// Three pieces of trust:
//   - the seq named dim threads through every op as a runtime-varying axis
//   - the explicit copy(x) calls are how linearity records the fan-out
//     into q, k, v (and norm1 into the MLP)
//   - the empty effect set means this is pure forward — RNG-free.
def forward(
  x:      tensor[seq, 256, f32],
  wq:     tensor[256, 64,   f32],
  wk:     tensor[256, 64,   f32],
  wv:     tensor[256, 64,   f32],
  wo:     tensor[64,  256,  f32],
  ff1:    tensor[256, 1024, f32],
  ff2:    tensor[1024, 256, f32],
  gamma1: tensor[256, f32],
  beta1:  tensor[256, f32],
  gamma2: tensor[256, f32],
  beta2:  tensor[256, f32]
) -> tensor[seq, 256, f32] = {
  // self-attention: q, k, v all read from x — three explicit copies
  q = matmul(copy(x), wq)
  k = matmul(copy(x), wk)
  v = matmul(copy(x), wv)

  // (seq x 64) @ (64 x seq) -> (seq x seq)
  scores   = matmul(q, permute(k, 1, 0))
  probs    = softmax(scores, 1)

  // (seq x seq) @ (seq x 64) -> (seq x 64); -> (seq x 256)
  attn_out = matmul(matmul(probs, v), wo)

  // residual + post-norm. Re-uses x via copy from above; here add(x, ...)
  // consumes x for the last time.
  norm1 = layer_norm(add(x, attn_out), gamma1, beta1)

  // mlp via pipe; copy(norm1) for the second residual fanout
  ff_out = matmul(copy(norm1), ff1) |> relu |> matmul(ff2)

  layer_norm(add(norm1, ff_out), gamma2, beta2)
}
