module Hello.Proof_controls.Scaled_without_order
import Hello.Basics.PropertyProof (scaled)
-- Removing the input-order guard makes the monotonicity claim false.
@property scaled_without_order forall(x1: f32, x2: f32):
  (scaled(x2) > scaled(x1))
