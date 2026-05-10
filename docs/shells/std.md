# `chelis-std`

The standard library. Always available, no extra `[dependencies]` line
needed beyond the implicit one in `reef.toml`.

Pinned to `0.3.0`.

## What's here

| Module | Surface |
|---|---|
| `Std.Tensor.Construct` | `to_tensor`, literal-list construction, `expand`, `pad_sequences` |
| `Std.Tensor.Reduce` | `sum`, `mean`, `max_reduce`, `softmax`, `argmax`, `argmin`, `all`, `any` |
| `Std.Tensor.Mask` | `where`, `where_indices`, `cmplt`, `eq`, `neq`, `gt`, `lte`, `gte` |
| `Std.Nn.Activation` | `relu`, `sigmoid`, `tanh`, `gelu`, `silu`, `softmax`, `log_softmax` |
| `Std.Nn.Norm` | `layer_norm`, `rms_norm`, `batch_norm`, `group_norm` |
| `Std.Nn.Loss` | `mse`, `cross_entropy`, `bce`, `huber`, `kl_div` |
| `Std.Nn.Random` | `uniform`, `normal`, `bernoulli`, `categorical` (effect-typed `! { Random }`) |
| `Std.LinAlg` | `transpose`, `inverse`, `det`, `trace`, `eye`, `diag` |
| `Std.Time` | `DateTime`, `Duration`, `Period`, `BusinessDay` |
| `Std.Decimal` | `Decimal[P, S]` with compile-time precision tracking |
| `Std.List` | `List[T]`, `len`, `index`, `append`, `concat`, `take`, `drop`, `chunk`, `flatten`, `range`, `zip`, `enumerate`, `to_tensor`, `to_list`, `pad_sequences` |
| `Std.Dict` | `Dict[K, V]`, `dict_of`, `dict_get`, `dict_insert`, `dict_remove`, `dict_merge`, `dict_keys`, `dict_values`, `dict_entries`, `dict_contains` |
| `Std.Iter` | `map`, `filter`, `fold`, `scan`, `partition`, `flat_map` |
| `Std.Io` | `read_tensor`, `write_tensor`, CSV/JSON/Safetensors helpers (`! { IO }`) |
| `Std.Test` | `assert_*` family — every test function is `! { Test }` |

## Stable vs moving surface

The
[`chelis-std/SKILL.md`](https://github.com/Chelis-Lang/chelis/blob/main/packages/chelis-std/SKILL.md)
in upstream chelis is the authoritative list of names that the type checker
accepts on the current snapshot. Names not on that list (or marked
"do not invent") are reserved for future use and won't compile today —
the corpus here stays inside that boundary.

## Examples in this repo

See [`src/std/`](../../src/std/) — catalog at
[`src/std/README.md`](../../src/std/README.md).
