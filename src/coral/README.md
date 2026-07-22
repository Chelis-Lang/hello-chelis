# `src/coral/` — typed dataframes

Tour of [Coral](https://github.com/Chelis-Lang/coral), the
pandas-equivalent shell. Numeric columns are tensor-backed, so dataframe
construction and tensor computation share one typed package graph.

Pinned to `coral` v0.7.31.

## Files

| File | Surface | Notes |
|---|---|---|
| [`framebasics.ch`](framebasics.ch) | `Coral.Frame` | `from_pairs`, typed columns (`FloatCol`/`IntCol`/`StringCol`), `with_column`, `rename`, `drop_column` |
| [`groupbyagg.ch`](groupbyagg.ch) | `Coral.GroupBy` | `group_by` + `agg_sum`/`agg_mean`/`agg_count` |
| [`joins.ch`](joins.ch) | `Coral.Join` | `inner_join`, `left_join`, `outer_join` |
| [`windowrolling.ch`](windowrolling.ch) | `Coral.Window` | rolling mean/std + EWM |
| [`reshape.ch`](reshape.ch) | `Coral.Reshape` | pivot, melt |
| [`io.ch`](io.ch) | `Coral.Io` | CSV / JSON round-trip (effect-typed `! { IO }`) |
| [`adthroughdataframe.ch`](adthroughdataframe.ch) | tensor grad beside Frame construction | builds a `Frame` from a tensor and separately pins direct tensor-loss grad at runtime |

The full export list and Coral-specific gotchas (e.g. `IntCol(values, mask)`)
live in [`docs/shells/coral.md`](../../docs/shells/coral.md).

## What's verified

| Lane | Coverage |
|---|---|
| `chelis check src/coral/<file>.ch` | every file passes with fitness 1.0 |
| `chelis test tests/coral/` | 18 runtime assertions across 7 modules |

`tests/coral/adthroughdataframe.ch` now executes the direct tensor gradient and
asserts `2w`. It does not claim that `group_by`, joins, or the `Frame` ADT itself
are differentiated; the example's Frame path establishes typed construction and
shape only.
