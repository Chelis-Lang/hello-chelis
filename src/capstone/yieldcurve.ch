module Hello.Capstone.YieldCurve
import Shoals.Curves (YieldCurve, bootstrap_zero_from_par, discount_factor, rate_at, parallel_shift, key_rate_shift)
export (par_curve, gapped_curve, bond_price, zero_rate, dv01, key_rate_sensitivity)
def par_curve() -> YieldCurve[5] = bootstrap_zero_from_par(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)]), to_tensor([cast(0.03, f32), cast(0.032, f32), cast(0.034, f32), cast(0.035, f32), cast(0.036, f32)]))
def gapped_curve() -> YieldCurve[4] = bootstrap_zero_from_par(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(5.0, f32)]), to_tensor([cast(0.03, f32), cast(0.032, f32), cast(0.034, f32), cast(0.036, f32)]))
def zero_rate[n](c: YieldCurve[n], t: f32) -> f32 = rate_at(c, t)
def bond_price[n](c: YieldCurve[n], cpn: f32) -> f32 = fold(fn (acc: f32, t: f32) -> add(acc, mul(if eq(t, cast(5.0, f32)) then add(cast(1.0, f32), cpn) else cpn, discount_factor(c, t))), cast(0.0, f32), [cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32), cast(5.0, f32)])
def dv01(cpn: f32) -> f32 = sub(bond_price(parallel_shift(par_curve(), cast(0.0001, f32)), cpn), bond_price(par_curve(), cpn))
def key_rate_sensitivity(pillar: i64, cpn: f32) -> f32 = sub(bond_price(key_rate_shift(par_curve(), pillar, cast(0.0001, f32)), cpn), bond_price(par_curve(), cpn))
