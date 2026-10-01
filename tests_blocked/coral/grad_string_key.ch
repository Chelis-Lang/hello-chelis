module Hello.TestsBlocked.Coral.GradStringKey
import Coral.Frame (FloatCol, from_pairs, get_float_col)
import Std.Test (assert_close_tensor)
def loss(w: tensor[3, f32]) -> tensor[f32] = {
  df = from_pairs([("w", FloatCol(w))])
  x = get_float_col(df, "w")
  sum(mul(x, x), 0)
}
def dloss(w: tensor[3, f32]) -> tensor[3, f32] = grad(loss, wrt=w)(w)
def test_grad_through_string_key() -> unit ! { Test } = {
  w = to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)])
  expected = to_tensor([cast(2.0, f32), cast(4.0, f32), cast(6.0, f32)])
  assert_close_tensor(dloss(w), expected, cast(0.00001, f32), "grad_string_key")
}
