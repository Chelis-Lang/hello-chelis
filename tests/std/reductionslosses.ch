module Hello.Tests.Std.ReductionsLosses

import Hello.Std.ReductionsLosses (kl_loss, ce_perplexity)
import Std.Test (assert_close)

-- The IR evaluator supports `add`, `sum`, `mean`, `softmax`, etc., on
-- tensors but not all loss helpers can be exercised at runtime in
-- v0.6.1 (e.g. CrossEntropy uses `log` which is unsupported on the
-- evaluator). We exercise a scalar loss path instead.

def test_kl_loss_self_is_zero() -> unit ! { Test } = {
  p = to_tensor([cast(0.5, f32), cast(0.5, f32)])
  q = to_tensor([cast(0.5, f32), cast(0.5, f32)])
  -- log(0.5) - log(0.5) = 0, so KL(p||p) = 0.
  result = kl_loss(p, q)
  assert_close(result, cast(0.0, f32), cast(1e-6, f32), "KL(p||p)=0")
}

def test_perplexity_zero_loss_is_one() -> unit ! { Test } = {
  -- exp(0) = 1.
  result = ce_perplexity(cast(0.0, f32))
  assert_close(result, cast(1.0, f32), cast(1e-6, f32), "perplexity(0)=1")
}

def test_perplexity_unit_loss() -> unit ! { Test } = {
  -- exp(1) ~= 2.71828...
  result = ce_perplexity(cast(1.0, f32))
  assert_close(result, cast(2.7182817, f32), cast(1e-4, f32), "perplexity(1)=e")
}
