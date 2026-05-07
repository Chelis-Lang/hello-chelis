// chelis-expect-fail: precision_mismatch
//
// f32 and bf16 must not mix without an explicit `cast`. The compiler
// must reject this with the `precision_mismatch` diagnostic and a
// suggestion to insert `cast`.

module Hello.Negative.PrecisionMismatch

def bad(x: tensor[n, f32], y: tensor[n, bf16]) -> tensor[n, f32] =
  add(x, y)
