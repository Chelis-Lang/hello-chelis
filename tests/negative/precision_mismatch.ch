-- chelis-expect-fail: PrecisionMismatch
--
-- f32 and f64 must not mix without an explicit cast. The compiler
-- must reject this with the precision_mismatch diagnostic and a
-- suggestion to insert cast.

def bad(x: tensor[n, f32], y: tensor[n, f64]) -> tensor[n, f32] =
  add(x, y)
