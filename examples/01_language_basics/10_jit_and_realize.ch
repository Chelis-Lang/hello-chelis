module Hello.Basics.JitRealize

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

// Three transforms:
//
//   - `jit(f)` lifts `f` into the build-target form: when invoked, it
//     compiles a specialized DAG once and reuses it.
//   - `realize(e)` forces a deferred expression to evaluate now, instead
//     of being kept as a thunk for fusion.
//   - `cast(x, t)` is the precision-changing transform we already used in
//     example 05; here it appears alongside its siblings to show that all
//     three are compiler keywords, not library calls.

def linear_relu(w: tensor[features, hidden, f32], x: tensor[features, f32]) -> tensor[hidden, f32] = {
  preact = matmul(x, w)
  relu(realize(preact))
}

// `jit(linear_relu)` returns a build-target version. Calling it is what
// you'd do in production code paths where the same shape is reused many
// times.
def jit_linear_relu(w: tensor[features, hidden, f32], x: tensor[features, f32]) -> tensor[hidden, f32] =
  jit(linear_relu)(w, x)

// And `cast` to demonstrate the keyword-not-library nature.
def to_bf16_then_back(x: tensor[n, f32]) -> tensor[n, f32] =
  cast(cast(x, bf16), f32)

def test_linear_relu() -> unit ! { Test } = {
  w = to_tensor([
    [1.0, 0.0],
    [0.0, 1.0],
    [1.0, 1.0]
  ])
  x = to_tensor([1.0, 0.0 - 2.0, 3.0])
  out = linear_relu(w, x)
  // x*w_col0 = 1 + 0 + 3 = 4 -> relu -> 4
  // x*w_col1 = 0 + (-2) + 3 = 1 -> relu -> 1
  expected = to_tensor([4.0, 1.0])
  assert_close_tensor(out, expected, 1e-6, "linear_relu")
}

def test_jit_matches_eager() -> unit ! { Test } = {
  w = to_tensor([
    [1.0, 0.0],
    [0.0, 1.0],
    [1.0, 1.0]
  ])
  x = to_tensor([1.0, 0.0 - 2.0, 3.0])
  out_jit = jit_linear_relu(w, x)
  expected = to_tensor([4.0, 1.0])
  assert_close_tensor(out_jit, expected, 1e-6, "jit_linear_relu")
}

def test_cast_roundtrip() -> unit ! { Test } = {
  x = to_tensor([1.0, 2.0, 4.0])
  out = to_bf16_then_back(x)
  assert_close_tensor(out, x, 1e-2, "bf16_roundtrip")
}
