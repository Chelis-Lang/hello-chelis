-- chelis-expect-fail: ArityMismatch
module Hello.Tests_Neg.Check.KeylessUniform
def keyless(template: tensor[3, f32]) -> tensor[3, f32] = uniform_like(template, 0.0f32, 1.0f32)
