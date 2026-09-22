# `src/std/` — chelis-std surfaces

Tour of the standard-library surface bundled with compiler v0.18.11, plus the
School 0.1.14 neural-network/loss modules that moved out of `chelis-std` 0.4.0.
The collection, tensor, time, decimal, and I/O examples use the bundled
runtime; activation and loss examples import the pinned School package.

## Files

| File | Surface | Notes |
|---|---|---|
| [`activationsnorms.ch`](activationsnorms.ch) | tensor builtins + `School.Nn.*` | tensor `relu`/`sigmoid`/`silu`/`gelu`/`tanh`, RMS / layer norm |
| [`reductionslosses.ch`](reductionslosses.ch) | tensor reductions + `School.Loss.*` | sum/mean/prod axis reductions, cross-entropy, BCE, KL, perplexity |
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
