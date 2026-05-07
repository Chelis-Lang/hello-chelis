module Hello.Std.CollectionsIteration

import Std.Test (assert_eq_int, assert_eq_string)

// Lists, Dicts, and the higher-order iteration vocabulary. All shipped in
// chelis-std under Std.List, Std.Dict, Std.Iter. Mirrors examples/list_foundation.ch
// and examples/iter_foundation.ch in the upstream chelis repo.

def collect_summary() -> int64 = {
  xs: List[int64] = [cast(1, int64), cast(2, int64), cast(3, int64), cast(4, int64)]

  // Higher-order iteration.
  doubled = map(fn (x: int64) -> mul(x, cast(2, int64)), xs)
  evens   = filter(fn (x: int64) -> eq(mod(x, cast(2, int64)), cast(0, int64)), doubled)
  total   = fold(fn (acc: int64, x: int64) -> add(acc, x), cast(0, int64), evens)

  // List ops.
  longer = concat(xs, [cast(5, int64), cast(6, int64)])
  trimmed = drop(longer, cast(2, int64))     // [3, 4, 5, 6]
  chunked = chunk(trimmed, cast(2, int64))   // [[3,4], [5,6]]

  add(total, cast(len(chunked), int64))
}

def vocab_count() -> int64 = {
  // Dict construction from a list of pairs.
  vocab: Dict[string, int64] = dict_of([
    ("alpha", cast(1, int64)),
    ("beta",  cast(2, int64))
  ])
  extended = dict_insert(vocab, "gamma", cast(3, int64))
  cast(len(dict_entries(extended)), int64)
}

def test_summary() -> unit ! { Test } = {
  // doubled = [2, 4, 6, 8]; evens = same (all even); total = 20
  // chunked has 2 elements. 20 + 2 = 22.
  assert_eq_int(collect_summary(), cast(22, int64), "collect_summary")
}

def test_vocab() -> unit ! { Test } = {
  assert_eq_int(vocab_count(), cast(3, int64), "vocab_count")
}

def test_string_compose() -> unit ! { Test } = {
  s = string_concat("hello-", "chelis")
  assert_eq_string(s, "hello-chelis", "string_compose")
}
