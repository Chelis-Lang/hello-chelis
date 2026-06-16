# `src/std/` — chelis-std surfaces

Tour of the standard library that ships with the compiler at v0.7.26.
Every file here imports from `Std.*` and demonstrates a different
slice of the runtime that's available without any third-party shell.

## Files

| File | Surface | Notes |
|---|---|---|
| [`activationsnorms.ch`](activationsnorms.ch) | `Std.Nn.Activation`, `Std.Nn.Norm` | tensor `relu`/`sigmoid`/`silu`/`gelu`/`tanh`, RMS / layer norm |
| [`reductionslosses.ch`](reductionslosses.ch) | `Std.Tensor.Reduce`, `Std.Nn.Loss` | sum/mean/prod axis reductions, cross-entropy, BCE, KL, perplexity |
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
| `chelis test tests/std/` | 20 runtime assertions across 6 modules |
| Surf-Deep equivalence | every `.ch` paired with a machine-generated `.dp` |
