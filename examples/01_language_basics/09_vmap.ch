module Hello.Basics.Vmap

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close_tensor)

// `vmap` lifts a per-example function over a batch dimension. Write the
// per-example version once, get the batched version automatically — the
// compiler adds an axis to every type in scope.

def process(x: tensor[features, f32]) -> tensor[features, f32] =
  relu(x)

// vmap over axis 0: tensor[batch, features, f32] -> tensor[batch, features, f32].
def batch_process(xs: tensor[batch, features, f32]) -> tensor[batch, features, f32] =
  xs |> vmap(process, axis=0)

def test_batch_process() -> unit ! { Test } = {
  // batch=2, features=3
  in_ = to_tensor([
    [0.0 - 1.0, 0.0, 1.0],
    [2.0, 0.0 - 3.0, 4.0]
  ])
  out = batch_process(in_)
  expected = to_tensor([
    [0.0, 0.0, 1.0],
    [2.0, 0.0, 4.0]
  ])
  assert_close_tensor(out, expected, 1e-6, "batch_relu")
}
