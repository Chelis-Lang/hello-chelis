module Hello.Std.ActivationsNorms

import Std.Tensor.Construct (to_tensor)
import Std.Nn.Activation (relu, sigmoid, tanh, gelu, silu, softmax, log_softmax)
import Std.Nn.Norm (layer_norm, rms_norm)
import Std.Test (assert_close_tensor, assert_close)

// Activations: every one is `tensor[..., t] -> tensor[..., t]`,
// preserving the named-dim list.

def stack_relu_sigmoid(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> relu |> sigmoid

def stack_gelu_silu(x: tensor[n, f32]) -> tensor[n, f32] =
  x |> gelu |> silu

def softmax_last(x: tensor[batch, hidden, f32]) -> tensor[batch, hidden, f32] =
  softmax(x, 1)

// Layer norm takes its statistics-bearing parameters as ordinary tensors.
def normed(x: tensor[batch, hidden, f32], gamma: tensor[hidden, f32], beta: tensor[hidden, f32]) -> tensor[batch, hidden, f32] =
  layer_norm(x, gamma, beta)

def test_relu_sigmoid_zeros() -> unit ! { Test } = {
  x = to_tensor([0.0, 0.0, 0.0])
  out = stack_relu_sigmoid(x)
  // sigmoid(relu(0)) = sigmoid(0) = 0.5
  expected = to_tensor([0.5, 0.5, 0.5])
  assert_close_tensor(out, expected, 1e-6, "relu_sigmoid_zeros")
}

def test_softmax_sums_to_one() -> unit ! { Test } = {
  x = to_tensor([[1.0, 2.0, 3.0]])
  probs = softmax_last(x)
  total = sum(probs, 1)
  // sum across hidden axis => 1.0 per row
  s = sum(total, 0)
  assert_close(s, 1.0, 1e-6, "softmax_simplex")
}
