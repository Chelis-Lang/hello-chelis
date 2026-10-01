module Hello.Std.Reductions
export (sum_axis0, mean_axis0, prod_axis0, sum_rows)
def sum_axis0[r, c](x: &tensor[r, c, f32]) -> tensor[c, f32] = sum(x, 0i32)
def mean_axis0(x: &tensor[3, 4, f32]) -> tensor[4, f32] = mean(x, 0i32)
def prod_axis0[r, c](x: &tensor[r, c, f32]) -> tensor[c, f32] = prod_reduce(x, 0i32)
def sum_rows[r, c](x: &tensor[r, c, f32]) -> tensor[r, f32] = sum(x, 1i32)
