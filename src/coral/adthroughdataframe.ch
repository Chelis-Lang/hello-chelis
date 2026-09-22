module Hello.Coral.AdThroughDataFrame
import Coral.Frame (Frame, Column, FloatCol, from_pairs, nrows)
export (frame_shape_check, simple_loss, dsimple_loss_dw)
def frame_shape_check[n](w: tensor[n, f32]) -> i64 = {
  df = from_pairs([("w", FloatCol(w))])
  nrows(df)
}
def simple_loss[n](w: tensor[n, f32]) -> tensor[f32] = {
  prod = mul(w, w)
  sum(prod, 0)
}
def dsimple_loss_dw[n](w: tensor[n, f32]) -> tensor[n, f32] = grad(simple_loss, wrt=w)(w)
