module Hello.Proof_controls.Parabola_wrong
import Hello.Nautilus.Optimize (parabola)
@property parabola_minimum_too_high_wrong forall(x: f32):
  (parabola(x) >= 8.0f32)
@property parabola_box_upper_too_low_wrong forall(x: f32) where x >= 3.1f32, x <= 3.9f32:
  (parabola(x) <= 7.5f32)
