module Hello.Properties.BlackScholesGreeks
import Hello.Capstone.BlackScholes (delta, vega)
-- European call Greeks on a finite spot box with fixed positive model inputs.
@property delta_box_lower forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (delta(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32) >= 0.0f32)
@property delta_box_upper forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (delta(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32) <= 1.0f32)
@property vega_box_lower forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (vega(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32) >= 0.0f32)
@property vega_box_upper forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (vega(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32) <= 42.0f32)
