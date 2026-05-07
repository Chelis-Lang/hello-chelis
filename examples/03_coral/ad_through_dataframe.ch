module Hello.Coral.AdThroughDataframe

import Std.Tensor.Construct (to_tensor)
import Std.Tensor.Reduce (sum)
import Coral.Frame (Frame, from_pairs, get_float_col, with_column, int_col_of_list)
import Coral.GroupBy (group_by, agg_sum)
import Std.Test (assert_close, assert_close_tensor)

// The headline Coral capability: `grad` flows through dataframe operations
// because numeric columns are tensor-backed and group_by / agg / join are
// implemented as tensor ops with proper backward-pass plumbing.
//
// Concretely: we build a frame from a learnable weight vector, group_by
// city, agg_sum over qty * weight, and the gradient of the city-summed
// totals with respect to the input weights flows correctly.

// Forward: sum-of-weighted-quantities, grouped by city.
def grouped_total(weights: tensor[n, f32]) -> tensor[f32] = {
  city_codes = int_col_of_list([cast(0, int64), cast(1, int64), cast(0, int64), cast(1, int64)])
  qty = FloatCol(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32)]))
  weighted = FloatCol(mul(get_float_col_inner(qty), weights))
  // Build frame from the learnable weighted column
  frame = from_pairs([
    ("city", IntCol(city_codes_inner(city_codes), bool_mask_for_4())),
    ("wq",   weighted)
  ])
  totals = agg_sum(group_by(frame, "city"), "wq")
  sum(get_float_col(totals, "wq"), 0)
}

// helpers — ordinarily Coral exports these directly; named here for clarity
def get_float_col_inner(c: FloatCol) -> tensor[n, f32] =
  match c with { | FloatCol(values) => values }

def city_codes_inner(c: IntCol) -> tensor[n, int64] =
  match c with { | IntCol(values, _) => values }

def bool_mask_for_4() -> tensor[n, bool] =
  // all-valid mask for 4 entries
  eq(to_tensor([cast(0, int64), cast(0, int64), cast(0, int64), cast(0, int64)]),
     to_tensor([cast(0, int64), cast(0, int64), cast(0, int64), cast(0, int64)]))

def test_forward() -> unit ! { Test } = {
  w = to_tensor([1.0, 1.0, 1.0, 1.0])
  // qty * w = [1, 2, 3, 4]; group_by city -> london=[1,3]=4, paris=[2,4]=6
  // sum-of-totals = 10
  assert_close(grouped_total(w), 10.0, 1e-6, "grouped_total_unit_w")
}

def test_grad_flows() -> unit ! { Test } = {
  w = to_tensor([1.0, 1.0, 1.0, 1.0])
  // d(sum_of_totals)/dw_i = qty_i (each w contributes qty_i once).
  out = grad(grouped_total)(w)
  expected = to_tensor([1.0, 2.0, 3.0, 4.0])
  assert_close_tensor(out, expected, 1e-6, "grad_through_groupby")
}
