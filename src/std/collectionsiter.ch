module Hello.Std.CollectionsIter

export (sum_evens, running_sums, build_vocab, lookup_or_default, take_first_three, double_then_pairs, increments, partition_threshold)

-- Filter a list of int64 to even numbers and sum them via fold.
def sum_evens(xs: List[int64]) -> int64 = {
  evens = filter(fn (x: int64) -> eq(mod(x, cast(2, int64)), cast(0, int64)), xs)
  fold(fn (acc: int64, x: int64) -> add(acc, x), cast(0, int64), evens)
}

-- Prefix sums via `scan`.
def running_sums(xs: List[int64]) -> List[int64] =
  scan(fn (acc: int64, x: int64) -> add(acc, x), cast(0, int64), xs)

-- Build a string -> int64 dict from parallel lists.
def build_vocab(keys: List[string], ids: List[int64]) -> Dict[string, int64] =
  dict_of(zip(keys, ids))

-- Look up a key with a fallback default.
def lookup_or_default(d: Dict[string, int64], k: string, fallback: int64) -> int64 = {
  match dict_get(d, k) with {
    | Some(value) => value
    | None => fallback
  }
}

-- Map increment by 1 over a list (illustrates `map`).
def increments(xs: List[int64]) -> List[int64] =
  map(fn (x: int64) -> add(x, cast(1, int64)), xs)

-- Take the first three elements, dropping the rest.
def take_first_three(xs: List[int64]) -> List[int64] =
  take(xs, cast(3, int64))

-- For each element x, emit [x, 2*x] using `flat_map`.
def double_then_pairs(xs: List[int64]) -> List[int64] =
  flat_map(fn (x: int64) -> [x, mul(x, cast(2, int64))], xs)

-- Partition by `> threshold`. Returns the `gt` bucket as the first
-- component (a tuple of two lists in the order produced by the prim).
def partition_threshold(xs: List[int64], threshold: int64) =
  partition(fn (x: int64) -> gt(x, threshold), xs)
