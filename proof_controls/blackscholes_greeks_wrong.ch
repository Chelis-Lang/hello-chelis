module Hello.Proof_controls.Blackscholes_greeks_wrong
import Hello.Capstone.BlackScholes (delta, vega)
@property delta_box_nonpositive_wrong forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (delta(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32) <= 0.0f32)
@property vega_box_nonpositive_wrong forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (vega(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32) <= 0.0f32)
