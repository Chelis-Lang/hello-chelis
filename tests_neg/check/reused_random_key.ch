-- chelis-expect-fail: KeyReuse
module Hello.Tests_Neg.Check.ReusedRandomKey
def reused(template: tensor[3, f32]) -> tensor[3, f32] = {
  k = key_from_seed(42i64)
  _ = uniform_like(k, copy(template), 0.0f32, 1.0f32)
  uniform_like(k, template, 0.0f32, 1.0f32)
}
