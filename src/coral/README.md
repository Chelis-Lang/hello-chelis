# `src/coral/`: typed dataframes

A tour of [Coral](https://github.com/Chelis-Lang/coral), a pandas-like
dataframe package. Frames carry their row count in the type (`Frame[3]`), and
numeric columns are tensors.

| File | Module | What it shows |
|---|---|---|
| [`framebasics.ch`](framebasics.ch) | `Coral.Frame` | `from_pairs`, float / int / string columns, `with_column`, `rename`, `drop_column` |
| [`groupbyagg.ch`](groupbyagg.ch) | `Coral.GroupBy` | `group_by` with `agg_sum` and `agg_mean` |
| [`joins.ch`](joins.ch) | `Coral.Join` | `inner_join`, `left_join`, `outer_join` |
| [`windowrolling.ch`](windowrolling.ch) | `Coral.Window` | `rolling_mean`, `rolling_std`, `ewm` |
| [`reshape.ch`](reshape.ch) | `Coral.Reshape` | `pivot` and `melt` |
| [`io.ch`](io.ch) | `Coral.Io` | a CSV write and read round trip |
| [`adthroughdataframe.ch`](adthroughdataframe.ch) | `Coral.Frame` | a frame built from a learnable tensor, and `grad` of a loss on that tensor |

Each file has a test of the same name under [`tests/coral/`](../../tests/coral/).
Coral's own documentation is in the
[Coral repository](https://github.com/Chelis-Lang/coral).

## Notes

- Build integer columns with `int_col_of_list([...])`, as `framebasics.ch`
  does, rather than calling the `IntCol` constructor directly.
- **Differentiating through frame operations is not yet possible.** Column
  access is keyed by a string name, and `grad` cannot yet evaluate a function
  that uses a string
  ([chelis#2552](https://github.com/Chelis-Lang/chelis/issues/2552)). So
  `adthroughdataframe.ch` differentiates the tensor loss directly, and a
  separate function shows that the same tensor becomes a frame column.
