module Hello.Nautilus.RootsBrent

import Nautilus.Roots (bisect, newton, brent)
import Std.Test (assert_close)

// f(x) = x^2 - 2; root in (0, 2) is sqrt(2) ~= 1.41421356
def f(x: tensor[f32]) -> tensor[f32] = add(mul(x, copy(x)), to_tensor_scalar(0.0 - 2.0))

// f'(x) = 2x
def fprime(x: tensor[f32]) -> tensor[f32] = mul(x, to_tensor_scalar(2.0))

def to_tensor_scalar(v: f32) -> tensor[f32] = to_scalar_tensor(v)

// helper — Std doesn't ship a 0d-tensor literal, so we go through to_tensor.
def to_scalar_tensor(v: f32) -> tensor[f32] = sum(to_tensor([v]), 0)

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)

def test_bisect_sqrt2() -> unit ! { Test } = {
  r = bisect(f, cast(0.0, f32), cast(2.0, f32), cast(1e-6, f32), cast(100, int64))
  assert_close(r, 1.41421356, 1e-4, "bisect_sqrt2")
}

def test_brent_sqrt2() -> unit ! { Test } = {
  r = brent(f, cast(0.0, f32), cast(2.0, f32), cast(1e-6, f32), cast(100, int64))
  assert_close(r, 1.41421356, 1e-4, "brent_sqrt2")
}

def test_newton_sqrt2() -> unit ! { Test } = {
  r = newton(f, fprime, cast(1.5, f32), cast(1e-6, f32), cast(50, int64))
  assert_close(r, 1.41421356, 1e-4, "newton_sqrt2")
}
