module Hello.Tests.Basics.EffectsRandom
import Hello.Basics.EffectsRandom (deterministic_pair)
import Std.Test (assert_close_tensor)
def test_seeded_draw_is_repeatable() -> unit ! { Test } = assert_close_tensor(deterministic_pair(), deterministic_pair(), cast(0.0, f32), "seeded_repeatable")
