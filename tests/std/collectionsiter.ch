module Hello.Tests.Std.CollectionsIter
import Hello.Std.CollectionsIter (sum_evens, increments, take_first_three, build_vocab, lookup_or_default)
import Std.Test (assert_eq)
def test_sum_evens() -> unit ! { Test } = {
  xs: List[i64] = [1i64, 2i64, 3i64, 4i64, 5i64]
  result = sum_evens(xs)
  assert_eq(result, 6i64, "sum of evens in [1..5]")
}
def test_increments_length() -> unit ! { Test } = {
  xs: List[i64] = [10i64, 20i64, 30i64]
  bumped = increments(xs)
  assert_eq(len(bumped), 3i64, "increments preserves length")
}
def test_take_three() -> unit ! { Test } = {
  xs: List[i64] = [10i64, 20i64, 30i64, 40i64]
  taken = take_first_three(xs)
  assert_eq(len(taken), 3i64, "take 3 from 4")
}
def test_vocab_lookup() -> unit ! { Test } = {
  keys: List[string] = ["alpha", "beta", "gamma"]
  ids: List[i64] = [1i64, 2i64, 3i64]
  vocab = build_vocab(keys, ids)
  hit = lookup_or_default(vocab, "beta", -1i64)
  assert_eq(hit, 2i64, "beta -> 2")
}
