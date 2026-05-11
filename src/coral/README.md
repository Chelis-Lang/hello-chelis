# `src/coral/` — typed dataframes

Tour of [Coral](https://github.com/Chelis-Lang/coral), the
pandas-equivalent shell. Numeric columns are tensor-backed, which is
why dataframe pipelines compose with the rest of the Chelis tensor
DAG — `grad` flows through `group_by`, AD flows through joins, etc.

Pinned to `coral` v0.7.6.

## Files

| File | Surface | Notes |
|---|---|---|
| [`framebasics.ch`](framebasics.ch) | `Coral.Frame` | `from_pairs`, typed columns (`FloatCol`/`IntCol`/`StringCol`), `with_column`, `rename`, `drop_column` |
| [`groupbyagg.ch`](groupbyagg.ch) | `Coral.GroupBy` | `group_by` + `agg_sum`/`agg_mean`/`agg_count` |
| [`joins.ch`](joins.ch) | `Coral.Join` | `inner_join`, `left_join`, `outer_join` |
| [`windowrolling.ch`](windowrolling.ch) | `Coral.Window` | rolling mean/std + EWM |
| [`reshape.ch`](reshape.ch) | `Coral.Reshape` | pivot, melt |
| [`io.ch`](io.ch) | `Coral.Io` | CSV / JSON round-trip (effect-typed `! { IO }`) |
| [`adthroughdataframe.ch`](adthroughdataframe.ch) | grad through Frame | the headline capability — building a `Frame` from a learnable tensor and differentiating through it |

The full export list and Coral-specific gotchas (e.g. `IntCol(values, mask)`)
live in [`docs/shells/coral.md`](../../docs/shells/coral.md).

## What's verified

| Lane | Coverage |
|---|---|
| `chelis check src/coral/<file>.ch` | every file passes with fitness 1.0 |
| `chelis test tests/coral/` | 18 runtime assertions across 7 modules |

The autodiff-through-dataframe example uses a structural shape rather
than calling `grad` at runtime — the IR evaluator at v0.7.6 doesn't
yet lower `grad` over the `Frame` ADT. The `chelis check` verifies the
gradient definition; the runtime exercise lives in
[`verify/grad_works.ch`](../../verify/grad_works.ch).
