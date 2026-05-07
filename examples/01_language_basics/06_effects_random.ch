module Hello.Basics.EffectsRandom

import Std.Tensor.Construct (to_tensor)
import Std.Nn.Random (uniform, normal)
import Std.Test (assert_close, assert_shape)

// Effects show up in function signatures after the return type, between
// `!` braces. A function that touches `Std.Nn.Random.uniform` picks up
// `! { Random }`, and that effect propagates through every caller.

sig sample_uniform: () -> tensor[n, f32] ! { Random }
def sample_uniform() -> tensor[n, f32] ! { Random } = uniform([3])

// Without a handler, callers also carry `! { Random }`.
def sum_two_samples() -> tensor[n, f32] ! { Random } =
  add(sample_uniform(), sample_uniform())

// `with seed(...)` is the algebraic-effect-style handler that DISCHARGES
// the Random effect. Inside the block, `uniform` and friends draw from a
// deterministic stream seeded on the constant. Outside the block, the
// caller's effect set no longer contains Random.
def deterministic_pair() -> tensor[n, f32] = {
  with seed(42) {
    sum_two_samples()
  }
}

// You can also handle Random higher up. This function is pure — its
// inferred effect set is `! {}`.
def deterministic_summary() -> tensor[f32] = {
  with seed(7) {
    s = sample_uniform()
    sum(s, 0)
  }
}

def test_deterministic_pair_shape() -> unit ! { Test } = {
  out = deterministic_pair()
  assert_shape(out, cast(3, int64), "deterministic_pair_shape")
}

def test_deterministic_pair_is_repeatable() -> unit ! { Test } = {
  // Two calls under the same seed must return the same value.
  // (assert_close compares element 0 of each.)
  a = deterministic_pair()
  b = deterministic_pair()
  // pull element 0 via reduction over a 1-elem tensor
  a0 = sum(to_tensor([index(to_list(a), cast(0, int64))]), 0)
  b0 = sum(to_tensor([index(to_list(b), cast(0, int64))]), 0)
  assert_close(a0, b0, 1e-6, "deterministic_pair_repeatable")
}
