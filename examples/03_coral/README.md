# 03 — coral (typed dataframes)

Each example is adapted from the working patterns in
[Coral SKILL.md](https://github.com/Chelis-Lang/coral/blob/main/SKILL.md).

| File | Surface |
|---|---|
| [`frame_basics.ch`](frame_basics.ch) | `from_pairs`, typed columns, `with_column`, `rename` |
| [`groupby_agg.ch`](groupby_agg.ch) | `group_by` + `agg_sum` / `agg_mean` |
| [`joins.ch`](joins.ch) | inner / left / outer joins on string keys |
| [`window_rolling.ch`](window_rolling.ch) | `rolling_mean`, `rolling_std`, `ewm` |
| [`reshape_pivot.ch`](reshape_pivot.ch) | `pivot`, `melt` |
| [`csv_json_io.ch`](csv_json_io.ch) | `Coral.Io` round-trip |
| [`ad_through_dataframe.ch`](ad_through_dataframe.ch) | `grad` flowing through `group_by` + `agg_sum` |
