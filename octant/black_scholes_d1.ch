-- Black-Scholes d_1 helper:
--   d = (log(s/k) + (r + sigma^2 / 2) t) / (sigma sqrt(t))
-- Hand-written reference paired with black_scholes_d1.tex.

def d(s: f32, k: f32, r: f32, t: f32, sigma: f32) -> f32 =
  div(
    add(
      log(div(s, k)),
      mul(add(r, div(mul(sigma, sigma), 2)), t)
    ),
    mul(sigma, sqrt(t))
  )
