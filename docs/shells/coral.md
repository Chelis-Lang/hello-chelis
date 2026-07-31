# `coral`

Typed dataframes for Chelis. Numeric columns are tensors, which means
dataframe pipelines compose with the rest of the Chelis tensor DAG:
`grad` flows through a `group_by`, AD flows through a join.

Pinned to `0.7.32`. Reef declaration in our [`reef.toml`](../../reef.toml).

## What's here

| Module | Surface |
|---|---|
| `Coral.Frame` | `Frame`, `from_pairs`, `FloatCol`, `IntCol(values, mask)`, `StringCol`, `BoolCol`, `int_col_of_list`, `with_column`, `rename`, `drop_column`, `filter`, `sort_by`, `concat`, `describe`, NaN helpers |
| `Coral.GroupBy` | `group_by` + `agg_sum` / `agg_mean` / `agg_count` / `agg_min` / `agg_max`, `value_counts` |
| `Coral.Join` | `inner_join`, `left_join`, `outer_join` |
| `Coral.Window` | `rolling_mean`, `rolling_std`, `rolling_max`, `ewm` |
| `Coral.Reshape` | `pivot`, `melt`, `stack`, `unstack` |
| `Coral.Io` | `read_csv_frame`, `write_csv_frame`, `read_json_frame`, `write_json_frame` (Parquet upstream-blocked) |

## Gotchas

- **Integer columns** use a two-field `IntCol(values, bool_mask)`
  representation. Always construct via `int_col_of_list([...])`, not
  `IntCol(to_tensor([...]))` directly.
- **Float NaN** uses non-suffixed helpers (`fill_nan`, `drop_nan`); int NaN
  uses `_col` suffix helpers that take a `Frame` + column name.
- **Parquet is upstream-blocked** as of the pinned toolchain. `import Std.Io.Parquet`
  resolves at check time; runtime symbol is missing so link fails. Skip it
  in examples.

## Examples in this repo

See [`src/coral/`](../../src/coral/) — catalog at
[`src/coral/README.md`](../../src/coral/README.md).

The headline example is
[`adthroughdataframe.ch`](../../src/coral/adthroughdataframe.ch),
which builds a `Frame` from a learnable tensor and demonstrates `grad`
flowing through the column-construction path. The runtime exercise of
`grad` itself lives in [`verify/grad_works.ch`](../../verify/grad_works.ch)
(the IR evaluator at the pinned toolchain doesn't lower `grad` over the `Frame` ADT
yet — see [`docs/discrepancies.md`](../discrepancies.md)).
