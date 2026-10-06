# `src/std/`: the standard library

Tour of the standard-library surface intended for compiler v0.18.13. Every
example here uses only the bundled runtime and the language builtins.

| File | Uses | What it shows |
|---|---|---|
| [`elementwise.ch`](elementwise.ch) | elementwise builtins + `Std.Iter` | `relu` as a non-negative clamp, logistic `sigmoid` and `tanh` (tensor and scalar forms), z-score standardization, RMS scaling |
| [`reductions.ch`](reductions.ch) | tensor reductions | sum/mean/prod reductions along an axis |
| [`decimal.ch`](decimal.ch) | `Std.Decimal` | exact decimal arithmetic for prices and tax |
| [`datetimecal.ch`](datetimecal.ch) | `Std.Datetime` | calendar arithmetic, weekday lookup, formatting |
| [`collectionsiter.ch`](collectionsiter.ch) | `Std.List`, `Std.Dict`, `Std.Iter` | `List[T]` + `Dict[K, V]` + `map`/`filter`/`fold`/`scan` |
| [`tensorio.ch`](tensorio.ch) | `Std.Io` | text I/O round-trip with the `! { IO }` effect declared at every boundary |

The supported examples have matching tests under [`tests/std/`](../../tests/std/).
Decimal and date assertions run under [`tests/std/`](../../tests/std/).

For the full API, see the `chelis-std` reference in
[`packages/chelis-std/SKILL.md`](https://github.com/Chelis-Lang/chelis/blob/main/packages/chelis-std/SKILL.md).
