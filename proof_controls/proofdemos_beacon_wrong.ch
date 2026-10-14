module Hello.Proof_controls.Proofdemos_beacon_wrong
import Hello.Proofdemos.ProbabilityBudget (normal_tail_reserve)
import Hello.Proofdemos.OptionRisk (report_delta, report_vega)
-- Beacon must exhibit checked point witnesses for these false claims.
@property beacon_reserve_zero_wrong forall(z: f32) where z >= -2.0f32, z <= 2.0f32:
  (normal_tail_reserve(z) <= 0.0f32)
@property beacon_delta_zero_wrong forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (report_delta(s) <= 0.0f32)
@property beacon_vega_zero_wrong forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (report_vega(s) <= 0.0f32)
