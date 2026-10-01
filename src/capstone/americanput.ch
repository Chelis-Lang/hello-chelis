module Hello.Capstone.AmericanPut
import Shoals.Pricing (bs_put_scalar)
import Shoals.Trees (tr_crr_american_put)
import Shoals.Pde (pde_american_put_cn)
import Nautilus.Distributions (normal_cdf)
import Nautilus.Roots (brent)
export (european_put, tree_put, grid_put, exercise_exponent, critical_price, approximate_put)
def european_put(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = bs_put_scalar(s, k, r, sigma, t)
def tree_put(s: f32, k: f32, r: f32, sigma: f32, t: f32, steps: i64) -> f32 = tr_crr_american_put(s, k, r, cast(0.0, f32), sigma, t, steps)
def grid_put(s: f32, k: f32, r: f32, sigma: f32, t: f32, nodes: i64, steps: i64) -> f32 = pde_american_put_cn(s, k, r, cast(0.0, f32), sigma, t, nodes, steps, cast(4.0, f32))
def d1(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = div(add(log(div(s, k)), mul(add(r, mul(cast(0.5, f32), mul(sigma, sigma))), t)), mul(sigma, sqrt(t)))
def exercise_exponent(r: f32, sigma: f32, t: f32) -> f32 = {
  m = div(mul(cast(2.0, f32), r), mul(sigma, sigma))
  kk = sub(cast(1.0, f32), exp(neg(mul(r, t))))
  div(sub(sub(cast(1.0, f32), m), sqrt(add(mul(sub(m, cast(1.0, f32)), sub(m, cast(1.0, f32))), div(mul(cast(4.0, f32), m), kk)))), cast(2.0, f32))
}
def critical_price(k: f32, r: f32, sigma: f32, t: f32) -> f32 = brent(fn (s: f32) -> sub(sub(k, s), sub(bs_put_scalar(s, k, r, sigma, t), div(mul(sub(cast(1.0, f32), normal_cdf(neg(d1(s, k, r, sigma, t)), cast(0.0, f32), cast(1.0, f32))), s), exercise_exponent(r, sigma, t)))), mul(cast(0.2, f32), k), k, cast(1e-6, f32), cast(200, i64))
def approximate_put(s: f32, k: f32, r: f32, sigma: f32, t: f32) -> f32 = {
  q1 = exercise_exponent(r, sigma, t)
  ss = critical_price(k, r, sigma, t)
  a1 = neg(mul(div(ss, q1), sub(cast(1.0, f32), normal_cdf(neg(d1(ss, k, r, sigma, t)), cast(0.0, f32), cast(1.0, f32)))))
  if lte(s, ss) then sub(k, s) else add(bs_put_scalar(s, k, r, sigma, t), mul(a1, exp(mul(q1, log(div(s, ss))))))
}
