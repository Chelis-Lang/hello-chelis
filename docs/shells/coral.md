# `coral`

Typed dataframes for Chelis. Numeric columns are tensors, which means
dataframe construction and tensor computation share one typed package graph.

Pinned to `0.7.31`. Reef declaration in our [`reef.toml`](../../reef.toml).

## What's here

| Module | Surface |
|---|---|
| `Coral.Frame` | `Frame`, `from_pairs`, `FloatCol`, `IntCol(values, mask)`, `StringCol`, `BoolCol`, `int_col_of_list`, `with_column`, `rename`, `drop_column`, `filter`, `sort_by`, `concat`, `describe`, NaN helpers |
| `Coral.GroupBy` | `group_by` + `agg_sum` / `agg_mean` / `agg_count` / `agg_min` / `agg_max`, `value_counts` |
| `Coral.Join` | `inner_join`, `left_join`, `outer_join` |
| `Coral.Window` | `rolling_mean`, `rolling_std`, `rolling_max`, `ewm` |
| `Coral.Reshape` | `pivot`, `melt`, `stack`, `unstack` |
| `Coral.Io` | `read_csv_frame`, `write_csv_frame`, `read_json_frame`, `write_json_frame`; Parquet is an explicit package stub |

## Gotchas

- **Integer columns** use a two-field `IntCol(values, bool_mask)`
  representation. Always construct via `int_col_of_list([...])`, not
  `IntCol(to_tensor([...]))` directly.
- **Float NaN** uses non-suffixed helpers (`fill_nan`, `drop_nan`); int NaN
  uses `_col` suffix helpers that take a `Frame` + column name.
- **Parquet is unavailable** at Coral `0.7.31`: `Coral.Io` implements both
  Parquet functions as explicit `fail(...)` stubs. The expected blocker lives
  in `tests_blocked/coral/parquet.ch`.

## Examples in this repo

See [`src/coral/`](../../src/coral/) — catalog at
[`src/coral/README.md`](../../src/coral/README.md).

The headline example is
[`adthroughdataframe.ch`](../../src/coral/adthroughdataframe.ch),
which builds a `Frame` from a tensor and independently executes the gradient
of a tensor loss. It does not claim AD through the `Frame` ADT, joins, or
`group_by`; see [`docs/discrepancies.md`](../discrepancies.md).
