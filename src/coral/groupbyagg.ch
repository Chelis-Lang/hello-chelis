module Hello.Coral.GroupByAgg
import Coral.Frame (Frame, Column, from_pairs, nrows, ncols, get_float_col)
import Coral.GroupBy (group_by, agg_sum, agg_mean)
export (sales_frame, total_per_city, mean_per_city)
def sales_frame() -> Frame[4] = { from_pairs([("city", StringCol(["a", "b", "a", "b"])), ("qty", FloatCol(to_tensor([cast(1.0, f32), cast(10.0, f32), cast(2.0, f32), cast(20.0, f32)])))]) }
def total_per_city() -> Frame[2] = { agg_sum(group_by(sales_frame(), "city"), "qty") }
def mean_per_city() -> Frame[2] = { agg_mean(group_by(sales_frame(), "city"), "qty") }
