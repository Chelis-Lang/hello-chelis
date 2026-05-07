module Hello.Std.ReductionsLosses

import Std.Loss.CrossEntropy (loss)
import Std.Loss.Bce (bce_with_logits)
import Std.Loss.KlDiv (kl_divergence)
import Std.Loss.Metrics (perplexity)
import Std.Tensor.Reduce (prod)

export (sum_axis0, mean_axis0, prod_axis0, ce_loss, bce_loss, kl_loss, ce_perplexity)

-- Sum a 2D tensor along axis 0 producing a row of column-sums.
def sum_axis0[r, c](x: tensor[r, c, f32]) -> tensor[c, f32] =
  sum(x, cast(0, int32))

-- Mean of each column (axis 0). Uses fixed dimensions so the IR
-- evaluator can lower the reduce.
def mean_axis0(x: tensor[3, 4, f32]) -> tensor[4, f32] =
  mean(x, cast(0, int32))

-- Product of each column (axis 0).
def prod_axis0[r, c](x: tensor[r, c, f32]) -> tensor[c, f32] =
  prod(x, cast(0, int32))

-- Per-batch cross entropy loss given logits and one-hot labels.
def ce_loss[b, c](logits: tensor[b, c, f32], labels: tensor[b, c, f32]) -> tensor[b, f32] =
  loss(logits, labels)

-- Per-element binary cross entropy with logits.
def bce_loss[n](z: tensor[n, f32], y: tensor[n, f32]) -> tensor[n, f32] =
  bce_with_logits(z, y)

-- KL divergence between two probability vectors.
def kl_loss[n](p: tensor[n, f32], q: tensor[n, f32]) -> f32 =
  kl_divergence(p, q)

-- Perplexity is exp(loss) — useful for converting CE to a readable metric.
def ce_perplexity(scalar_loss: f32) -> f32 =
  perplexity(scalar_loss)
