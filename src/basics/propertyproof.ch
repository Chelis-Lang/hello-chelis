module Hello.Basics.PropertyProof
export (scaled)
def scaled(x: f32) -> f32 = ((2.0f32 * x) + 1.0f32)
-- For a larger input, this function gives a larger output in real arithmetic.
@property scaled_monotone forall(x1: f32, x2: f32) where x2 > x1:
  (scaled(x2) > scaled(x1))
