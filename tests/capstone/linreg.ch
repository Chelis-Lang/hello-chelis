module Hello.Tests.Capstone.LinReg

import Hello.Capstone.LinReg (predict, mse_loss)
import Std.Test (assert_close)

-- Smoke test: at w=0, b=0, predict returns zero, mse_loss equals mean(y^2).
-- We use 64x64 design matrix and 64x1 targets all set to 0 -> loss = 0.

def zeros_64_64() -> tensor[64, 64, f32] =
  expand(expand(to_tensor([cast(0.0, f32)]), 0, 64), 1, 64)

def zeros_64_1() -> tensor[64, 1, f32] =
  expand(expand(to_tensor([cast(0.0, f32)]), 0, 64), 1, 1)

def zeros_1() -> tensor[1, f32] =
  to_tensor([cast(0.0, f32)])

def test_loss_zero_at_zero() -> unit ! { Test } = {
  x = zeros_64_64()
  y = zeros_64_1()
  w = zeros_64_1()
  b = zeros_1()
  assert_close(mse_loss(x, y, w, b), cast(0.0, f32), cast(1e-6, f32), "loss_zero_at_zero")
}
