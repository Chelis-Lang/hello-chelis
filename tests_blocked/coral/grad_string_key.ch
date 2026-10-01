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
  w = to_tensor([1.0f32, 2.0f32, 3.0f32])
  expected = to_tensor([2.0f32, 4.0f32, 6.0f32])
  assert_close_tensor(dloss(w), expected, 0.00001f32, "grad_string_key")
}
