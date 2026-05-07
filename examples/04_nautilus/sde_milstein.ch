module Hello.Nautilus.SdeMilstein

import Std.Tensor.Construct (to_tensor)
import Std.Nn.Random (normal)
import Nautilus.SDE (euler_maruyama, milstein)
import Std.Test (assert_close)

// Geometric Brownian motion: dS = mu*S dt + sigma*S dW.
// E[S_t] = S_0 * exp(mu * t). With mu = 0, E[S_t] = S_0.
// Caller supplies the noise increments.

def drift(t: tensor[f32], s: tensor[f32]) -> tensor[f32] = mul(s, to_tensor_scalar(0.0))
def diffusion(t: tensor[f32], s: tensor[f32]) -> tensor[f32] = mul(s, to_tensor_scalar(0.2))

def to_tensor_scalar(v: f32) -> tensor[f32] = sum(to_tensor([v]), 0)

import Std.Tensor.Reduce (sum)

// Run a deterministic-noise GBM path with `with seed` so the test is
// reproducible. With small step, expect the endpoint near 1.0 on average.
def gbm_endpoint() -> tensor[f32] = {
  with seed(11) {
    s0 = to_tensor_scalar(1.0)
    n_steps = cast(200, int64)
    dt = cast(0.005, f32)
    noise = normal_path(n_steps)
    euler_maruyama(drift, diffusion, s0, cast(0.0, f32), dt, noise)
  }
}

def normal_path(n: int64) -> tensor[m, f32] ! { Random } =
  normal([n])

def test_gbm_finite() -> unit ! { Test } = {
  // The mean over many paths -> 1.0 (martingale with mu=0). With one
  // seed and 200 steps, just assert finiteness within a wide band.
  out = gbm_endpoint()
  // 0 < S_T < 5 with overwhelming probability for these params + seed.
  // We assert close to 1.0 within band 1.0.
  assert_close(out, 1.0, 1.0, "gbm_endpoint_band")
}
