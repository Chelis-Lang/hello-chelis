module Hello.Basics.EffectsRandom
import Std.Init.Random (normal_like)
export (sample_normal, deterministic_pair)
sig sample_normal[n]: tensor[n, f32] -> tensor[n, f32] ! { Random }
def sample_normal(template: tensor[n, f32]) -> tensor[n, f32] ! { Random } = normal_like(template, cast(0.0, f32), cast(1.0, f32))
def deterministic_pair() -> tensor[3, f32] = with seed(42i64) { sample_normal(to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)])) }
