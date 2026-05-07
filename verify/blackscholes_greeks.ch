module BlackScholesGreeks

-- Black-Scholes call price + delta via `grad`. The wrapper-over-fn-
-- param form is the lowering-friendly pattern the C backend accepts.
--
-- Standard at-the-money setup: S=K=100, r=5%, sigma=20%, T=1 year.
-- Closed-form C ≈ 10.4506. Closed-form delta = N(d_1) ≈ 0.6368.

-- Standard normal CDF via erf identity:
--   N(x) = 0.5 * (1 + erf(x / sqrt(2)))
def std_normal_cdf(x: f32) -> f32 = {
  z = div(x, sqrt(cast(2.0, f32)))
  mul(cast(0.5, f32), add(cast(1.0, f32), erf(z)))
}

def d1(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  num = add(log(div(s, k)), mul(add(r, mul(cast(0.5, f32), mul(sigma, sigma))), t))
  den = mul(sigma, sqrt(t))
  div(num, den)
}

def call_price(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  d_1 = d1(s, k, r, sigma, t)
  d_2 = sub(d_1, mul(sigma, sqrt(t)))
  discount = exp(neg(mul(r, t)))
  sub(mul(s, std_normal_cdf(d_1)), mul(mul(k, discount), std_normal_cdf(d_2)))
}

-- delta = ∂C/∂s. The wrapper-over-fn-param form is what `chelis build`
-- demands for grad to lower.
def delta_via_grad(
  model: f32 -> f32 -> f32 -> f32 -> f32 -> f32,
  s: f32, k: f32, r: f32, sigma: f32, t: f32
) -> f32 = {
  target = fn (s_local: f32) -> model(s_local, k, r, sigma, t)
  grad(target, wrt=(s_local))(s)
}

s0 = cast(100.0, f32)
k0 = cast(100.0, f32)
r0 = cast(0.05, f32)
sigma0 = cast(0.20, f32)
t0 = cast(1.0, f32)

c = call_price(s0, k0, r0, sigma0, t0)
delta_ad = delta_via_grad(call_price, s0, k0, r0, sigma0, t0)
