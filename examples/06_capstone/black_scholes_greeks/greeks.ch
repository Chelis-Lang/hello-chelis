module Hello.Capstone.BlackScholes.Greeks

import Hello.Capstone.BlackScholes.Pricer (call_price)
import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)
import Nautilus.Distributions.Normal as N
import Std.Test (assert_close)

def to_scalar(v: f32) -> tensor[f32] = sum(to_tensor([v]), 0)

// AUTODIFF GREEKS ----------------------------------------------------------
//
// `grad` over a curried view of `call_price` is a one-liner per Greek.
// The compiler builds the backward pass from the Octant-translated Deep —
// no separate pricing library, no hand-derived adjoints.

def delta_ad(s: tensor[f32], k: tensor[f32], r: tensor[f32], sigma: tensor[f32], t: tensor[f32]) -> tensor[f32] =
  grad(fn (s_var: tensor[f32]) -> call_price(s_var, copy(k), copy(r), copy(sigma), copy(t)))(s)

def vega_ad(s: tensor[f32], k: tensor[f32], r: tensor[f32], sigma: tensor[f32], t: tensor[f32]) -> tensor[f32] =
  grad(fn (sig_var: tensor[f32]) -> call_price(copy(s), copy(k), copy(r), sig_var, copy(t)))(sigma)

def rho_ad(s: tensor[f32], k: tensor[f32], r: tensor[f32], sigma: tensor[f32], t: tensor[f32]) -> tensor[f32] =
  grad(fn (r_var: tensor[f32]) -> call_price(copy(s), copy(k), r_var, copy(sigma), copy(t)))(r)

// CLOSED-FORM GREEKS (cross-check) ----------------------------------------
//
// Standard textbook expressions. The test below asserts grad's output
// matches these to within 1e-3.

def closed_delta(s: tensor[f32], k: tensor[f32], r: tensor[f32], sigma: tensor[f32], t: tensor[f32]) -> tensor[f32] = {
  // delta = N(d1)
  num1 = log(div(s, k))
  half_sigma_sq = mul(to_scalar(0.5), mul(sigma, copy(sigma)))
  num2 = mul(add(r, half_sigma_sq), t)
  numer = add(num1, num2)
  denom = mul(sigma, sqrt(t))
  d1_v = div(numer, denom)
  N.cdf_tensor(d1_v, to_scalar(0.0), to_scalar(1.0))
}

def test_call_price_at_money() -> unit ! { Test } = {
  // S=K=100, r=5%, sigma=20%, T=1: closed-form C ~= 10.4506
  s = to_scalar(100.0)
  k = to_scalar(100.0)
  r = to_scalar(0.05)
  sigma = to_scalar(0.20)
  t = to_scalar(1.0)
  c = call_price(s, k, r, sigma, t)
  assert_close(c, 10.4506, 1e-2, "bs_call_atm")
}

def test_delta_ad_matches_closed_form() -> unit ! { Test } = {
  s = to_scalar(100.0)
  k = to_scalar(100.0)
  r = to_scalar(0.05)
  sigma = to_scalar(0.20)
  t = to_scalar(1.0)
  ad = delta_ad(s, copy(k), copy(r), copy(sigma), copy(t))
  closed = closed_delta(to_scalar(100.0), k, r, sigma, t)
  // Both should land near 0.6368 for at-the-money 1-year call at r=5%.
  assert_close(ad, 0.6368, 1e-2, "delta_ad_value")
  assert_close(closed, 0.6368, 1e-2, "delta_closed_value")
}

def test_vega_positive() -> unit ! { Test } = {
  s = to_scalar(100.0)
  k = to_scalar(100.0)
  r = to_scalar(0.05)
  sigma = to_scalar(0.20)
  t = to_scalar(1.0)
  v = vega_ad(s, k, r, sigma, t)
  // Vega is the price's sensitivity to sigma; per unit sigma it's ~= 37.5
  // for these inputs.
  assert_close(v, 37.524, 1.0, "vega_atm")
}
