module Hello.Basics.EffectsRandom
import Std.Init.Random (normal_like)
export (sample_normal, deterministic_pair, independent_pair)
sig sample_normal[n]: key -> tensor[n, f32] -> tensor[n, f32]
def sample_normal(rng_key: key, template: tensor[n, f32]) -> tensor[n, f32] = normal_like(rng_key, template, 0.0f32, 1.0f32)
def deterministic_pair() -> tensor[3, f32] = sample_normal(key_from_seed(42i64), to_tensor([0.0f32, 0.0f32, 0.0f32]))
def independent_pair() -> (tensor[3, f32], tensor[3, f32]) = {
  (first_key, second_key) = split_key(key_from_seed(42i64))
  template = to_tensor([0.0f32, 0.0f32, 0.0f32])
  (sample_normal(first_key, copy(template)), sample_normal(second_key, template))
}
