module Hello.Capstone.BlackScholes.Pricer

// Verified output of `octant translate black_scholes.tex`. Re-running
// translation must produce a byte-equal copy of this file.

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)
import Nautilus.Distributions.Normal as N

export (call_price)

def to_scalar(v: f32) -> tensor[f32] = sum(to_tensor([v]), 0)

// span: black_scholes.tex#eq:bs_d1_001
def d1(s: tensor[f32], k: tensor[f32], r: tensor[f32], sigma: tensor[f32], t: tensor[f32]) -> tensor[f32] = {
  num1 = log(div(s, k))
  half_sigma_sq = mul(to_scalar(0.5), mul(sigma, copy(sigma)))
  num2 = mul(add(r, half_sigma_sq), t)
  numer = add(num1, num2)
  denom = mul(sigma, sqrt(t))
  div(numer, denom)
}

// span: black_scholes.tex#eq:bs_d2_001
def d2(s: tensor[f32], k: tensor[f32], r: tensor[f32], sigma: tensor[f32], t: tensor[f32]) -> tensor[f32] =
  add(d1(copy(s), copy(k), copy(r), copy(sigma), copy(t)), neg(mul(sigma, sqrt(t))))

// span: black_scholes.tex#eq:bs_call_001
def call_price(s: tensor[f32], k: tensor[f32], r: tensor[f32], sigma: tensor[f32], t: tensor[f32]) -> tensor[f32] = {
  d1_v = d1(copy(s), copy(k), copy(r), copy(sigma), copy(t))
  d2_v = d2(copy(s), copy(k), copy(r), copy(sigma), copy(t))
  n_d1 = N.cdf_tensor(d1_v, to_scalar(0.0), to_scalar(1.0))
  n_d2 = N.cdf_tensor(d2_v, to_scalar(0.0), to_scalar(1.0))
  discount = exp(neg(mul(r, t)))
  add(mul(s, n_d1), neg(mul(mul(k, discount), n_d2)))
}
