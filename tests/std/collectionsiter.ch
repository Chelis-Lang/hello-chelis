module Hello.Tests.Std.CollectionsIter
import Hello.Std.CollectionsIter (sum_evens, increments, take_first_three, build_vocab, lookup_or_default)
import Std.Test (assert_eq)
def test_sum_evens() -> unit ! { Test } = {
  xs: List[i64] = [cast(1, i64), cast(2, i64), cast(3, i64), cast(4, i64), cast(5, i64)]
  result = sum_evens(xs)
  assert_eq(result, cast(6, i64), "sum of evens in [1..5]")
}
def test_increments_length() -> unit ! { Test } = {
  xs: List[i64] = [cast(10, i64), cast(20, i64), cast(30, i64)]
  bumped = increments(xs)
  assert_eq(len(bumped), cast(3, i64), "increments preserves length")
}
def test_take_three() -> unit ! { Test } = {
  xs: List[i64] = [cast(10, i64), cast(20, i64), cast(30, i64), cast(40, i64)]
  taken = take_first_three(xs)
  assert_eq(len(taken), cast(3, i64), "take 3 from 4")
}
def test_vocab_lookup() -> unit ! { Test } = {
  keys: List[string] = ["alpha", "beta", "gamma"]
  ids: List[i64] = [cast(1, i64), cast(2, i64), cast(3, i64)]
  vocab = build_vocab(keys, ids)
  hit = lookup_or_default(vocab, "beta", cast(-1, i64))
  assert_eq(hit, cast(2, i64), "beta -> 2")
}
