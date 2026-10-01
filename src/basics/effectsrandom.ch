module Hello.Basics.EffectsRandom
export (sample_uniform, deterministic_sample, independent_pair)
sig sample_uniform[n]: key -> tensor[n, f32] -> tensor[n, f32]
def sample_uniform(rng_key: key, template: tensor[n, f32]) -> tensor[n, f32] = uniform_like(rng_key, template, 0.0f32, 1.0f32)
def deterministic_sample() -> tensor[3, f32] = key_from_seed(42i64) |> sample_uniform(to_tensor([0.0f32, 0.0f32, 0.0f32]))
def independent_pair() -> (tensor[3, f32], tensor[3, f32]) = {
  (first_key, second_key) = key_from_seed(42i64) |> split_key
  template = to_tensor([0.0f32, 0.0f32, 0.0f32])
  (sample_uniform(first_key, template), sample_uniform(second_key, template))
}
