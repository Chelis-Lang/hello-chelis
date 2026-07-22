module Hello.Tests.Basics.EffectsRandom
import Hello.Basics.EffectsRandom (deterministic_pair)
import Std.Test (assert_close_tensor)
def test_seed_repeats() -> unit ! { Test } = {
  first = deterministic_pair()
  second = deterministic_pair()
  assert_close_tensor(first, second, cast(0.0, f32), "seed_repeats")
}
