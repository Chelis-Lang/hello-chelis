module Hello.Std.CollectionsIter
export (sum_evens, running_sums, build_vocab, lookup_or_default, take_first_three, double_then_pairs, increments, partition_threshold)
def sum_evens(xs: List[i64]) -> i64 = {
  evens = filter(fn (x: i64) -> (x |> mod(2i64) |> eq(0i64)), xs)
  fold(fn (acc: i64, x: i64) -> add(acc, x), 0i64, evens)
}
def running_sums(xs: List[i64]) -> List[i64] = scan(fn (acc: i64, x: i64) -> add(acc, x), 0i64, xs)
def build_vocab(keys: List[string], ids: List[i64]) -> Dict[string, i64] = keys |> zip(ids) |> dict_of
def lookup_or_default(d: Dict[string, i64], k: string, fallback: i64) -> i64 =
  match dict_get(d, k) with {
    | Some(value) => value
    | None => fallback
  }
def increments(xs: List[i64]) -> List[i64] = map(fn (x: i64) -> add(x, 1i64), xs)
def take_first_three(xs: List[i64]) -> List[i64] = take(xs, 3i64)
def double_then_pairs(xs: List[i64]) -> List[i64] = flat_map(fn (x: i64) -> [x, mul(x, 2i64)], xs)
def partition_threshold(xs: List[i64], threshold: i64) = partition(fn (x: i64) -> gt(x, threshold), xs)
