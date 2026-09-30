# `src/std/` — chelis-std surfaces

Tour of the standard-library surface bundled with compiler v0.18.11. Every
example here uses only the bundled runtime and the language builtins.

## Files

| File | Surface | Notes |
|---|---|---|
| [`elementwise.ch`](elementwise.ch) | elementwise builtins + `Std.Iter` | `relu` as a non-negative clamp, logistic `sigmoid` and `tanh` (tensor and scalar forms), z-score standardization, RMS scaling |
| [`reductions.ch`](reductions.ch) | tensor reductions | sum/mean/prod reductions along an axis |
| [`decimal.ch`](decimal.ch) | `Std.Decimal` | `Decimal[P, S]` exact arithmetic for prices, tax, currency |
| [`datetimecal.ch`](datetimecal.ch) | `Std.Time` | `DateTime`, `Duration`, weekday lookup, formatting |
| [`collectionsiter.ch`](collectionsiter.ch) | `Std.List`, `Std.Dict`, `Std.Iter` | `List[T]` + `Dict[K, V]` + `map`/`filter`/`fold`/`scan` |
| [`tensorio.ch`](tensorio.ch) | `Std.Io` | text I/O round-trip with the `! { IO }` effect declared at every boundary |

The full export list of `chelis-std` is in
[`docs/shells/std.md`](../../docs/shells/std.md).

## What's verified

| Lane | Coverage |
|---|---|
| `chelis check src/std/<file>.ch` | every file passes with fitness 1.0 |
| `chelis test tests/std/` | 23 runtime assertions across 6 modules |
| Surf-Deep equivalence | every `.ch` paired with a machine-generated `.dp` |
