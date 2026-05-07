module Hello.Basics.GradBasic

import Std.Tensor.Construct (to_tensor)
import Std.Test (assert_close, assert_close_tensor)

// `grad` is a language-level transform, not a library function. It does
// reverse-mode automatic differentiation. The argument is a function (or
// closure) that returns a scalar; `grad` returns a function that returns
// the gradient with respect to each input.

// f(w, x) = sum( (w * x - 1)^2 )
def loss(w: tensor[n, f32], x: tensor[n, f32]) -> tensor[f32] = {
  pred = mul(w, x)
  err = add(pred, neg(to_tensor([1.0, 1.0, 1.0])))
  err_copy = copy(err)
  sum(mul(err, err_copy), 0)
}

// At w = [1, 1, 1], x = [1, 1, 1]: pred = [1, 1, 1], err = [0, 0, 0],
// loss = 0, dL/dw = 2*err*x = [0, 0, 0].
def grad_loss_zero() -> tensor[n, f32] = {
  w = to_tensor([1.0, 1.0, 1.0])
  x = to_tensor([1.0, 1.0, 1.0])
  // grad(loss) returns d(loss)/dw at this w,x.
  grad(loss)(w, x)
}

// At w = [2, 2, 2], x = [1, 1, 1]: pred = [2, 2, 2], err = [1, 1, 1],
// loss = 3, dL/dw = 2*err*x = [2, 2, 2].
def grad_loss_step() -> tensor[n, f32] = {
  w = to_tensor([2.0, 2.0, 2.0])
  x = to_tensor([1.0, 1.0, 1.0])
  grad(loss)(w, x)
}

def test_loss_zero() -> unit ! { Test } = {
  w = to_tensor([1.0, 1.0, 1.0])
  x = to_tensor([1.0, 1.0, 1.0])
  out = loss(w, x)
  assert_close(out, 0.0, 1e-6, "loss_zero")
}

def test_grad_loss_zero() -> unit ! { Test } = {
  out = grad_loss_zero()
  expected = to_tensor([0.0, 0.0, 0.0])
  assert_close_tensor(out, expected, 1e-6, "grad_at_min")
}

def test_grad_loss_step() -> unit ! { Test } = {
  out = grad_loss_step()
  expected = to_tensor([2.0, 2.0, 2.0])
  assert_close_tensor(out, expected, 1e-6, "grad_step_off_min")
}
