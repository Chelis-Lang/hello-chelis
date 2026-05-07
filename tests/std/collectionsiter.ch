module Hello.Tests.Std.CollectionsIter

import Hello.Std.CollectionsIter (sum_evens, increments, take_first_three, build_vocab, lookup_or_default)
import Std.Test (assert_eq_int)

def test_sum_evens() -> unit ! { Test } = {
  xs: List[int64] = [cast(1, int64), cast(2, int64), cast(3, int64), cast(4, int64), cast(5, int64)]
  result = sum_evens(xs)
  assert_eq_int(result, cast(6, int64), "sum of evens in [1..5]")
}

def test_increments_length() -> unit ! { Test } = {
  xs: List[int64] = [cast(10, int64), cast(20, int64), cast(30, int64)]
  bumped = increments(xs)
  assert_eq_int(len(bumped), cast(3, int64), "increments preserves length")
}

def test_take_three() -> unit ! { Test } = {
  xs: List[int64] = [cast(10, int64), cast(20, int64), cast(30, int64), cast(40, int64)]
  taken = take_first_three(xs)
  assert_eq_int(len(taken), cast(3, int64), "take 3 from 4")
}

def test_vocab_lookup() -> unit ! { Test } = {
  keys: List[string] = ["alpha", "beta", "gamma"]
  ids: List[int64] = [cast(1, int64), cast(2, int64), cast(3, int64)]
  vocab = build_vocab(keys, ids)
  hit = lookup_or_default(vocab, "beta", cast(-1, int64))
  assert_eq_int(hit, cast(2, int64), "beta -> 2")
}
