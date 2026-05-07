module Hello.Basics.EffectsRandom

import Std.Init.Random (normal_like)

export (sample_normal)

-- Functions that touch randomness pick up `! { Random }` in their type.
-- The effect propagates: any caller without a handler also carries it,
-- and the type checker rejects calling `sample_normal` from a function
-- whose effect row doesn't include `Random`.
--
-- Discharging the Random effect with `with seed(...)` is shown in
-- verify/effects_handler.ch — the C backend's `with seed` plumbing
-- isn't fully landed on v0.6.1, so the seeded form lives in the
-- evaluator-only verify lane rather than in the project tree.
sig sample_normal: tensor[n, f32] -> tensor[n, f32] ! { Random }
def sample_normal(template: tensor[n, f32]) -> tensor[n, f32] ! { Random } =
  normal_like(template, cast(0.0, f32), cast(1.0, f32))
