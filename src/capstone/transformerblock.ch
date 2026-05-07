module Hello.Capstone.TransformerBlock

export (block)

-- Single-head transformer block. Adapted from the chelis/examples/
-- transformer_block.ch reference. The norm step is deferred to the
-- caller so the block stays self-contained at v0.6.1's primitives.
--
-- Three pieces of trust on display:
--   - the `seq` named dim threads through every op as a runtime-varying
--     axis; mismatches are compile errors before any tensor allocates
--   - explicit `copy(x)` calls record the fan-out into q, k, v, and
--     the residual's second consumer
--   - the empty effect set means this is pure forward — no Random, no IO

def block(
  x:   tensor[seq, 256, f32],
  wq:  tensor[256, 64,   f32],
  wk:  tensor[256, 64,   f32],
  wv:  tensor[256, 64,   f32],
  wo:  tensor[64,  256,  f32],
  ff1: tensor[256, 1024, f32],
  ff2: tensor[1024, 256, f32]
) -> tensor[seq, 256, f32] = {
  -- self-attention: q, k, v all read from x — three explicit copies
  q = matmul(copy(x), wq)
  k = matmul(copy(x), wk)
  v = matmul(copy(x), wv)

  -- (seq x 64) @ (64 x seq) -> (seq x seq)
  scores   = matmul(q, permute(k, 1, 0))
  probs    = softmax(scores, 1)

  -- (seq x seq) @ (seq x 64) -> (seq x 64); -> (seq x 256)
  attn_out = matmul(matmul(probs, v), wo)

  -- residual: add(x, ...) consumes x for the last time.
  resid1 = add(x, attn_out)

  -- mlp via pipe; copy(resid1) for the second residual fan-out
  ff_out = matmul(copy(resid1), ff1) |> matmul(ff2)

  add(resid1, ff_out)
}
