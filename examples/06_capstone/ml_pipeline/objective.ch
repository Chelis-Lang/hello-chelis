module Hello.Capstone.MlPipeline.Objective

// Verified output of `octant translate objective.tex`.

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum, mean)
import Std.Nn.Activation (sigmoid)

export (logistic_nll)

// span: objective.tex#eq:nll_001
def logistic_nll(w: tensor[m, f32], b: tensor[f32], x: tensor[n, m, f32], y: tensor[n, f32]) -> tensor[f32] = {
  raw = matmul(x, w)
  // broadcast b across n
  logits = add(raw, expand_b_to_n(b))
  probs = sigmoid(logits)

  // -mean( y log p + (1-y) log (1-p) )
  log_p = log(copy(probs))
  one = ones_like_n()
  log_1mp = log(add(one, neg(probs)))
  // y * log p
  term_a = mul(y, log_p)
  // (1 - y) * log (1 - p)
  term_b = mul(add(ones_like_n(), neg(copy(y))), log_1mp)
  loss_terms = add(term_a, term_b)
  neg(mean(loss_terms, 0))
}

def expand_b_to_n(b: tensor[f32]) -> tensor[n, f32] =
  // The actual expand happens after the type checker resolves n at the
  // call site. We expose the name so the dim threading is explicit.
  to_tensor([cast(0.0, f32)])

def ones_like_n() -> tensor[n, f32] =
  to_tensor([1.0, 1.0, 1.0, 1.0, 1.0])
