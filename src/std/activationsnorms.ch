module Hello.Std.ActivationsNorms

import Std.Nn.Silu (sigmoid_scalar)
import Std.Nn.Gelu (gelu_scalar, tanh_scalar)
import Std.Nn.RmsNorm (rms_scale)

export (relu_then_sigmoid, gelu_vec, silu_vec, tanh_vec, rms_normalize, manual_layer_norm, sigmoid_then_tanh, gelu_then_relu)

-- Compose tensor activations via the pipe operator. `relu` and
-- `sigmoid` are tensor primitives in scope without import.
def relu_then_sigmoid(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> relu |> sigmoid

-- Apply the GELU activation to every element of a vector.
def gelu_vec(x: tensor[n, f32]) -> tensor[n, f32] =
  to_tensor(map(fn (v: f32) -> gelu_scalar(v), to_list(x)))

-- Apply the SiLU/swish activation to every element of a vector.
def silu_vec(x: tensor[n, f32]) -> tensor[n, f32] =
  to_tensor(map(fn (v: f32) -> mul(v, sigmoid_scalar(v)), to_list(x)))

-- Apply tanh to every element of a vector via the scalar helper.
def tanh_vec(x: tensor[n, f32]) -> tensor[n, f32] =
  to_tensor(map(fn (v: f32) -> tanh_scalar(v), to_list(x)))

-- Pipe a tensor through GELU then a tensor `relu`.
def gelu_then_relu(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> gelu_vec |> relu

-- Pipe a tensor through scalar tanh then tensor sigmoid.
def sigmoid_then_tanh(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> sigmoid |> tanh_vec

-- RMS-normalize a vector with unit gain.
def rms_normalize(x: tensor[n, f32], eps: f32) -> tensor[n, f32] = {
  scale = rms_scale(copy(x), eps)
  to_tensor(map(fn (v: f32) -> mul(v, scale), to_list(x)))
}

-- Manual layer-norm: subtract mean and divide by std (chelis-std 0.2.0
-- doesn't ship a layer_norm helper, so we build one from primitives).
def manual_layer_norm(x: tensor[n, f32], eps: f32) -> tensor[n, f32] = {
  xs = to_list(copy(x))
  count = cast(len(xs), f32)
  total = fold(fn (acc: f32, v: f32) -> add(acc, v), cast(0.0, f32), xs)
  mu = div(total, count)
  centered = map(fn (v: f32) -> sub(v, mu), to_list(x))
  sq_sum = fold(fn (acc: f32, v: f32) -> add(acc, mul(v, v)), cast(0.0, f32), centered)
  variance = div(sq_sum, count)
  inv_std = div(cast(1.0, f32), sqrt(add(variance, eps)))
  to_tensor(map(fn (v: f32) -> mul(v, inv_std), centered))
}
