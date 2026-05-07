module Hello.Basics.EffectsRandom

import Std.Init.Random (normal_like)

export (sample_normal, deterministic_pair)

-- Functions that touch randomness pick up `! { Random }` in their type.
-- The effect propagates: any caller without a handler also carries it.
sig sample_normal: tensor[n, f32] -> tensor[n, f32] ! { Random }
def sample_normal(template: tensor[n, f32]) -> tensor[n, f32] ! { Random } =
  normal_like(template, cast(0.0, f32), cast(1.0, f32))

-- `with seed(42) { ... }` is the algebraic-effect-style handler that
-- discharges Random. Inside the block, `uniform_like`/`normal_like`
-- draw from a deterministic stream. Outside, the caller's effect set
-- no longer contains Random — this function's inferred effect is `! {}`.
def deterministic_pair() -> tensor[n, f32] = {
  with seed(42) {
    sample_normal(to_tensor([cast(0.0, f32), cast(0.0, f32), cast(0.0, f32)]))
  }
}
