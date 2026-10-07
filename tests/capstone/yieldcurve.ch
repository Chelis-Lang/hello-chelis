module Hello.Tests.Capstone.YieldCurve
import Hello.Capstone.YieldCurve (par_curve, gapped_curve, bond_price, zero_rate, dv01, key_rate_sensitivity)
import Std.Test (assert_close)
def test_bond_at_its_par_coupon_prices_at_par() -> unit ! { Test } = assert_close(bond_price(par_curve(), 0.036f32), 1.0f32, 0.00001f32, "a par-coupon bond on its own curve is worth face")
def test_zero_rate_5y() -> unit ! { Test } = assert_close(zero_rate(par_curve(), 5.0f32), 0.0355391f32, 0.00001f32, "5y continuous zero")
def test_premium_bond() -> unit ! { Test } = assert_close(bond_price(par_curve(), 0.04f32), 1.018089f32, 0.00001f32, "a 4% coupon above the 3.6% par yield prices above par")
def test_dv01() -> unit ! { Test } = assert_close(dv01(0.04f32), -0.00047141f32, 2e-6f32, "+1bp parallel loses about 4.7bp of price")
def test_key_rate_5y() -> unit ! { Test } = assert_close(key_rate_sensitivity(4i64, 0.04f32), -0.00043523f32, 2e-6f32, "the 5y pillar carries most of the risk")
def test_gapped_pillars_give_a_wrong_curve() -> unit ! { Test } = assert_close(zero_rate(gapped_curve(), 5.0f32), 0.0284362f32, 0.00001f32, "gapped pillars break the precondition")
