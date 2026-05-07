module Hello.Capstone.BlackScholes

import Nautilus.Distributions (normal_cdf)

export (call_price, delta, vega)

-- Black-Scholes European call price. Mirrors the LaTeX in
-- octant/black_scholes_call.tex.
--   d_1 = (ln(s/k) + (r + sigma^2 / 2) * t) / (sigma * sqrt(t))
--   d_2 = d_1 - sigma * sqrt(t)
--   c = s * N(d_1) - k * exp(-r * t) * N(d_2)
--
-- All-scalar to keep `grad` straightforward.

def d1(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  num = add(log(div(s, k)), mul(add(r, mul(cast(0.5, f32), mul(sigma, sigma))), t))
  den = mul(sigma, sqrt(t))
  div(num, den)
}

def d2(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 =
  sub(d1(s, k, r, sigma, t), mul(sigma, sqrt(t)))

def call_price(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  d_1 = d1(s, k, r, sigma, t)
  d_2 = d2(s, k, r, sigma, t)
  discount = exp(neg(mul(r, t)))
  sub(mul(s, normal_cdf(d_1, cast(0.0, f32), cast(1.0, f32))), mul(mul(k, discount), normal_cdf(d_2, cast(0.0, f32), cast(1.0, f32))))
}

-- Greeks via `grad`. Uses the wrapper-over-fn-param form so the C
-- backend lowers correctly: name a local closure that captures the
-- non-differentiated args, then grad(local, wrt=(arg))(arg).

def delta(
  model: f32 -> f32 -> f32 -> f32 -> f32 -> f32,
  s: f32, k: f32, r: f32, sigma: f32, t: f32
) -> f32 = {
  target = fn (s_local: f32) -> model(s_local, k, r, sigma, t)
  grad(target, wrt=(s_local))(s)
}

def vega(
  model: f32 -> f32 -> f32 -> f32 -> f32 -> f32,
  s: f32, k: f32, r: f32, sigma: f32, t: f32
) -> f32 = {
  target = fn (sigma_local: f32) -> model(s, k, r, sigma_local, t)
  grad(target, wrt=(sigma_local))(sigma)
}
