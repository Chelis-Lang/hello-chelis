module Hello.Std.ReductionsLosses

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum, mean, max_reduce)
import Std.Nn.Loss (mse, cross_entropy, huber, kl_div)
import Std.Test (assert_close)

// Reductions are named-axis aware. Pass the integer axis explicitly —
// reduction without an explicit axis is a parse error.

def total(x: tensor[n, f32]) -> tensor[f32] = sum(x, 0)
def avg(x: tensor[n, f32]) -> tensor[f32] = mean(x, 0)
def hi(x: tensor[n, f32]) -> tensor[f32] = max_reduce(x, 0)

// MSE between a prediction and a target.
def mse_loss(pred: tensor[n, f32], target: tensor[n, f32]) -> tensor[f32] =
  mse(pred, target)

// Huber is robust to outliers — quadratic close to zero, linear far away.
def huber_loss(pred: tensor[n, f32], target: tensor[n, f32]) -> tensor[f32] =
  huber(pred, target, 1.0)

def test_total() -> unit ! { Test } = {
  x = to_tensor([1.0, 2.0, 3.0, 4.0])
  assert_close(total(x), 10.0, 1e-6, "sum_1234")
}

def test_avg() -> unit ! { Test } = {
  x = to_tensor([2.0, 4.0, 6.0])
  assert_close(avg(x), 4.0, 1e-6, "mean_246")
}

def test_max() -> unit ! { Test } = {
  x = to_tensor([3.0, 1.0, 4.0, 1.0, 5.0, 9.0, 2.0, 6.0])
  assert_close(hi(x), 9.0, 1e-6, "max_pi_digits")
}

def test_mse_zero_when_equal() -> unit ! { Test } = {
  x = to_tensor([1.0, 2.0, 3.0])
  assert_close(mse_loss(x, copy(x)), 0.0, 1e-6, "mse_self")
}
