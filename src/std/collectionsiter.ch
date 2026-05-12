module Hello.Std.CollectionsIter
export (sum_evens, running_sums, build_vocab, lookup_or_default, take_first_three, double_then_pairs, increments, partition_threshold)
def sum_evens(xs: List[int64]) -> int64 = {
  evens = filter(fn (x: int64) -> x |> mod(cast(2, int64)) |> eq(cast(0, int64)), xs)
  fold(fn (acc: int64, x: int64) -> add(acc, x), cast(0, int64), evens)
}
def running_sums(xs: List[int64]) -> List[int64] = scan(fn (acc: int64, x: int64) -> add(acc, x), cast(0, int64), xs)
def build_vocab(keys: List[string], ids: List[int64]) -> Dict[string, int64] = keys |> zip(ids) |> dict_of
def lookup_or_default(d: Dict[string, int64], k: string, fallback: int64) -> int64 = { match dict_get(d, k) with {
  | Some(value) => value
  | None => fallback
} }
def increments(xs: List[int64]) -> List[int64] = map(fn (x: int64) -> add(x, cast(1, int64)), xs)
def take_first_three(xs: List[int64]) -> List[int64] = take(xs, cast(3, int64))
def double_then_pairs(xs: List[int64]) -> List[int64] = flat_map(fn (x: int64) -> [x, mul(x, cast(2, int64))], xs)
def partition_threshold(xs: List[int64], threshold: int64) = partition(fn (x: int64) -> gt(x, threshold), xs)
