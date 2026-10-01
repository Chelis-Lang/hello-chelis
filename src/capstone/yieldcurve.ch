module Hello.Capstone.YieldCurve
import Shoals.Curves (YieldCurve, bootstrap_zero_from_par, discount_factor, rate_at, parallel_shift, key_rate_shift)
export (par_curve, gapped_curve, bond_price, zero_rate, dv01, key_rate_sensitivity)
-- par yields on consecutive annual pillars: the precondition bootstrap_zero_from_par documents
def par_curve() -> YieldCurve[5] = bootstrap_zero_from_par(to_tensor([1.0f32, 2.0f32, 3.0f32, 4.0f32, 5.0f32]), to_tensor([0.03f32, 0.032f32, 0.034f32, 0.035f32, 0.036f32]))
-- the same market with the 4y pillar missing: it bootstraps without error, but the 5y zero is wrong
def gapped_curve() -> YieldCurve[4] = bootstrap_zero_from_par(to_tensor([1.0f32, 2.0f32, 3.0f32, 5.0f32]), to_tensor([0.03f32, 0.032f32, 0.034f32, 0.036f32]))
def zero_rate[n](c: YieldCurve[n], t: f32) -> f32 = rate_at(c, t)
-- a 5y annual-coupon bond with face value 1, discounted on the curve
def bond_price[n](c: YieldCurve[n], cpn: f32) -> f32 = fold(fn (acc: f32, t: f32) -> add(acc, mul(if eq(t, 5.0f32) then add(1.0f32, cpn) else cpn, discount_factor(c, t))), 0.0f32, [1.0f32, 2.0f32, 3.0f32, 4.0f32, 5.0f32])
-- price change for a +1bp parallel move, by bump-and-reprice
def dv01(cpn: f32) -> f32 = sub(bond_price(parallel_shift(par_curve(), 0.0001f32), cpn), bond_price(par_curve(), cpn))
-- price change for a +1bp move of one pillar (0-based index) only
def key_rate_sensitivity(pillar: i64, cpn: f32) -> f32 = sub(bond_price(key_rate_shift(par_curve(), pillar, 0.0001f32), cpn), bond_price(par_curve(), cpn))
