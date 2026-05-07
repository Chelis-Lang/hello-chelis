module Hello.Tests.Std.ActivationsNorms

import Hello.Std.ActivationsNorms (rms_normalize, manual_layer_norm)
import Std.Nn.Silu (sigmoid_scalar)
import Std.Nn.Gelu (gelu_scalar)
import Std.Test (assert_close)

-- The IR evaluator does not support `relu`/`sigmoid`/`tanh` as runtime
-- ops on tensors. We exercise the scalar helpers directly and the
-- pure-fold variants from the source module.

def test_sigmoid_scalar_zero() -> unit ! { Test } = {
  result = sigmoid_scalar(cast(0.0, f32))
  assert_close(result, cast(0.5, f32), cast(1e-6, f32), "sigmoid(0)=0.5")
}

def test_gelu_scalar_zero() -> unit ! { Test } = {
  result = gelu_scalar(cast(0.0, f32))
  assert_close(result, cast(0.0, f32), cast(1e-6, f32), "gelu(0)=0")
}

def test_manual_layer_norm_zero_mean() -> unit ! { Test } = {
  x = to_tensor([cast(-1.0, f32), cast(0.0, f32), cast(1.0, f32)])
  normed = manual_layer_norm(x, cast(1e-6, f32))
  -- Mean of layer-normed output should be ~0.
  total = fold(fn (acc: f32, v: f32) -> add(acc, v), cast(0.0, f32), to_list(normed))
  assert_close(total, cast(0.0, f32), cast(1e-4, f32), "layer_norm has zero mean")
}
