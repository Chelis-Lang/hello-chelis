module Hello.Proofdemos.CollateralBudget
import Shoals.FixedIncome (fi_bond2)
import Shoals.Csa (csa_collateralized_exposure)
export (bond_mark, unsecured_exposure, capital_buffer, collateral_report)
-- Mark a two-period, face-one coupon bond and scale it to a 1000-unit holding.
-- Both coupons move together. Yield is fixed in the coupon comparison below.
def bond_mark(coupon: f32, yield_rate: f32) -> f32 = (1000.0f32 * fi_bond2(coupon, yield_rate))
-- Apply one illustrative CSA: threshold 100, minimum transfer 25, independent
-- amount 50. A haircut removes a fraction of recognized collateral. The
-- nonnegative CSA parameters and haircut in [0, 1] are essential assumptions.
def unsecured_exposure(mark: f32, haircut: f32) -> f32 = csa_collateralized_exposure(mark, 100.0f32, 25.0f32, 50.0f32, haircut)
-- Reserve one eighth of the residual. This is an example policy, not a
-- regulatory capital formula, and does not predict a future bond price.
def capital_buffer(mark: f32, haircut: f32) -> f32 = (0.125f32 * unsecured_exposure(mark, haircut))
def collateral_report() -> (f32, f32, f32) = {
  mark = bond_mark(0.06f32, 0.05f32)
  (mark, unsecured_exposure(mark, 0.2f32), capital_buffer(mark, 0.2f32))
}
@property smt_coupon_raises_mark forall(c1: f32, c2: f32, y: f32) where c1 >= 0.0f32, c2 > c1, y >= 0.0f32:
  (bond_mark(c2, y) > bond_mark(c1, y))
@property smt_residual_lower forall(mark: f32, h: f32) where mark >= 0.0f32, h >= 0.0f32, h <= 1.0f32:
  (unsecured_exposure(mark, h) >= 0.0f32)
@property smt_residual_upper forall(mark: f32, h: f32) where mark >= 0.0f32, h >= 0.0f32, h <= 1.0f32:
  (unsecured_exposure(mark, h) <= mark)
@property smt_haircut_raises_residual forall(mark: f32, h1: f32, h2: f32) where mark >= 0.0f32, h1 >= 0.0f32, h1 <= h2, h2 <= 1.0f32:
  (unsecured_exposure(mark, h1) <= unsecured_exposure(mark, h2))
@property smt_capital_within_policy forall(mark: f32, h: f32) where mark >= 0.0f32, h >= 0.0f32, h <= 1.0f32:
  (capital_buffer(mark, h) <= (0.125f32 * mark))
