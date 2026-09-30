module Hello.Tests.Basics.EffectsRandom
import Hello.Basics.EffectsRandom (sample_normal, deterministic_pair, independent_pair)
import Std.Test (assert_true)
def template() -> tensor[3, f32] = to_tensor([0.0f32, 0.0f32, 0.0f32])
def test_explicit_key_replay() -> unit ! { Test } = {
  a = sample_normal(key_from_seed(42i64), template())
  b = sample_normal(key_from_seed(42i64), template())
  aa = to_list(a)
  bb = to_list(b)
  _ = assert_true(eq(index(aa, 0i64), index(bb, 0i64)), "equal seeds replay the first sample")
  assert_true(eq(index(aa, 2i64), index(bb, 2i64)), "equal seeds replay the last sample")
}
def test_split_keys_make_independent_draws() -> unit ! { Test } = {
  (first, second) = split_key(key_from_seed(7i64))
  a = sample_normal(first, template())
  b = sample_normal(second, template())
  assert_true(neq(index(to_list(a), 0i64), index(to_list(b), 0i64)), "child keys choose distinct draws")
}
def test_deterministic_pair_replays() -> unit ! { Test } = {
  a = deterministic_pair()
  b = deterministic_pair()
  assert_true(eq(index(to_list(a), 1i64), index(to_list(b), 1i64)), "the curriculum example replays")
}
def test_independent_pair_replays_both_children() -> unit ! { Test } = {
  first = independent_pair()
  replay = independent_pair()
  _ = assert_true(eq(index(to_list(first.0), 0i64), index(to_list(replay.0), 0i64)), "first child replays")
  assert_true(eq(index(to_list(first.1), 0i64), index(to_list(replay.1), 0i64)), "second child replays")
}
