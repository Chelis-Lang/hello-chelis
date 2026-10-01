module Hello.Capstone.AmericanPut
import Shoals.Pricing (bs_put_scalar)
import Shoals.Trees (tr_crr_american_put)
import Shoals.Pde (pde_american_put_cn)
import Nautilus.Distributions (normal_cdf)
import Nautilus.Roots (brent)
export (european_put, tree_put, grid_put, exercise_exponent, critical_price, approximate_put)
-- no dividends throughout (q = 0)
def european_put(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = bs_put_scalar(s, k, r, sigma, t)
-- Cox-Ross-Rubinstein binomial tree with early exercise at every node
def tree_put(s: f32, k: f32, r: f32, sigma: f32, t: f32, steps: i64) -> f32 = tr_crr_american_put(s, k, r, 0.0f32, sigma, t, steps)
-- Crank-Nicolson finite differences on a price grid up to 4 * k
def grid_put(s: f32, k: f32, r: f32, sigma: f32, t: f32, nodes: i64, steps: i64) -> f32 = pde_american_put_cn(s, k, r, 0.0f32, sigma, t, nodes, steps, 4.0f32)
-- Barone-Adesi-Whaley quadratic approximation
def d1(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = div(add(log(div(s, k)), mul(add(r, mul(0.5f32, mul(sigma, sigma))), t)), mul(sigma, sqrt(t)))
-- q1 = (-(m - 1) - sqrt((m - 1)^2 + 4m / (1 - exp(-rt)))) / 2 with m = 2r / sigma^2
def exercise_exponent(r: f32, sigma: f32, t: f32) -> f32 = {
  m = div(mul(2.0f32, r), mul(sigma, sigma))
  kk = sub(1.0f32, exp(neg(mul(r, t))))
  div(sub(sub(1.0f32, m), sqrt(add(mul(sub(m, 1.0f32), sub(m, 1.0f32)), div(mul(4.0f32, m), kk)))), 2.0f32)
}
-- the stock price below which exercising now is optimal: a root of the smooth-pasting condition
def critical_price(k: f32, r: f32, sigma: f32, t: f32) -> f32 = brent(fn (s: f32) -> sub(sub(k, s), sub(bs_put_scalar(s, k, r, sigma, t), div(mul(sub(1.0f32, normal_cdf(neg(d1(s, k, r, sigma, t)), 0.0f32, 1.0f32)), s), exercise_exponent(r, sigma, t)))), mul(0.2f32, k), k, 1e-6f32, 200i64)
def approximate_put(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  q1 = exercise_exponent(r, sigma, t)
  ss = critical_price(k, r, sigma, t)
  a1 = neg(mul(div(ss, q1), sub(1.0f32, normal_cdf(neg(d1(ss, k, r, sigma, t)), 0.0f32, 1.0f32))))
  if lte(s, ss) then sub(k, s) else add(bs_put_scalar(s, k, r, sigma, t), mul(a1, exp(mul(q1, log(div(s, ss))))))
}
