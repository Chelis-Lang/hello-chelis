module Hello.Tests.Capstone.YieldCurve
import Hello.Capstone.YieldCurve (par_curve, gapped_curve, bond_price, zero_rate, dv01, key_rate_sensitivity)
import Std.Test (assert_close)
def test_bond_at_its_par_coupon_prices_at_par() -> unit ! { Test } = assert_close(bond_price(par_curve(), cast(0.036, f32)), cast(1.0, f32), cast(0.00001, f32), "a par-coupon bond on its own curve is worth face")
def test_zero_rate_5y() -> unit ! { Test } = assert_close(zero_rate(par_curve(), cast(5.0, f32)), cast(0.0355391, f32), cast(0.00001, f32), "5y continuous zero")
def test_premium_bond() -> unit ! { Test } = assert_close(bond_price(par_curve(), cast(0.04, f32)), cast(1.018089, f32), cast(0.00001, f32), "a 4% coupon above the 3.6% par yield prices above par")
def test_dv01() -> unit ! { Test } = assert_close(dv01(cast(0.04, f32)), cast(-0.00047141, f32), cast(2e-6, f32), "+1bp parallel loses about 4.7bp of price")
def test_key_rate_5y() -> unit ! { Test } = assert_close(key_rate_sensitivity(cast(4, i64), cast(0.04, f32)), cast(-0.00043523, f32), cast(2e-6, f32), "the 5y pillar carries most of the risk")
def test_gapped_pillars_give_a_wrong_curve() -> unit ! { Test } = assert_close(zero_rate(gapped_curve(), cast(5.0, f32)), cast(0.0284362, f32), cast(0.00001, f32), "gapped pillars break the precondition")
