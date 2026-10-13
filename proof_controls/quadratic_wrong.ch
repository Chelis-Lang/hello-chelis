module Hello.Proof_controls.Quadratic_wrong
import Hello.Basics.QuadraticDescent (quadratic, gradient_step)
@property unrestricted_step_descends_wrong forall(x: f32):
  (quadratic(gradient_step(x, 1.5f32)) <= quadratic(x))
@property half_step_exceeds_minimum_wrong forall(x: f32):
  (quadratic(gradient_step(x, 0.5f32)) >= 8.0f32)
