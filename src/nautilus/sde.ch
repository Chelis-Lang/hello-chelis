module Hello.Nautilus.Sde

import Nautilus.Sde (euler_maruyama_fixed)

export (gbm_path_zero_noise, em_one_step_decay)

-- Drift mu*y for geometric Brownian motion (mu = 0.1).
def gbm_drift(y: f32, t: f32) -> f32 = mul(cast(0.1, f32), y)

-- Diffusion sigma*y for GBM (sigma = 0.2).
def gbm_diffusion(y: f32, t: f32) -> f32 = mul(cast(0.2, f32), y)

-- Pure linear-decay drift used to verify Euler-Maruyama collapses to
-- forward Euler when the noise vector is all zeros.
def decay_drift(y: f32, t: f32) -> f32 = neg(y)

-- g = 0 so EM is deterministic regardless of noise.
def zero_diffusion(y: f32, t: f32) -> f32 = cast(0.0, f32)

-- Simulate GBM from y0 = 1 over [0, 1] with all-zero noise (10 steps).
-- With zero noise, EM reduces to forward Euler on dy/dt = mu*y, which
-- approaches y(1) = exp(mu) = exp(0.1) ~ 1.10517 as n grows.
def gbm_path_zero_noise() -> f32 = {
  noise = to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32),
                     cast(0.0, f32), cast(0.0, f32), cast(0.0, f32),
                     cast(0.0, f32), cast(0.0, f32), cast(0.0, f32),
                     cast(0.0, f32)])
  euler_maruyama_fixed(gbm_drift, gbm_diffusion,
                       cast(1.0, f32), cast(0.0, f32), cast(1.0, f32), noise)
}

-- One EM step on dy/dt = -y, y0=1, dt=0.1, g=0 -> y_next = 0.9.
def em_one_step_decay() -> f32 = {
  noise = to_tensor([cast(0.0, f32)])
  euler_maruyama_fixed(decay_drift, zero_diffusion,
                       cast(1.0, f32), cast(0.0, f32), cast(0.1, f32), noise)
}
