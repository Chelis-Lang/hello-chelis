module Hello.Capstone.BlackScholes
import Nautilus.Distributions (normal_cdf)
export (call_price, delta, vega)
def d1(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  num = add(log(div(s, k)), mul(add(r, mul(0.5f32, mul(sigma, sigma))), t))
  den = mul(sigma, sqrt(t))
  div(num, den)
}
def d2(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = sub(d1(s, k, r, sigma, t), mul(sigma, sqrt(t)))
def call_price(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  d_1 = d1(s, k, r, sigma, t)
  d_2 = d2(s, k, r, sigma, t)
  discount = exp(neg(mul(r, t)))
  sub(mul(s, normal_cdf(d_1, 0.0f32, 1.0f32)), mul(mul(k, discount), normal_cdf(d_2, 0.0f32, 1.0f32)))
}
def delta(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = grad(call_price, wrt=s)(s, k, r, sigma, t)
def vega(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = grad(call_price, wrt=sigma)(s, k, r, sigma, t)
