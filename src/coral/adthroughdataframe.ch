module Hello.Coral.AdThroughDataFrame
import Coral.Frame (Frame, Column, from_pairs, nrows)
export (frame_shape_check, simple_loss, dsimple_loss_dw)
def frame_shape_check(w: tensor[n, f32]) -> int64 = {
  df = from_pairs([("w", FloatCol(w))])
  nrows(df)
}
def simple_loss(w: tensor[n, f32]) -> tensor[f32] = {
  prod = mul(copy(w), w)
  __borrow_migration_out_0 = sum(prod, 0)
  _ = drop(prod)
  __borrow_migration_out_0
}
def dsimple_loss_dw(w: tensor[n, f32]) -> tensor[n, f32] = grad(simple_loss, wrt=w)(w)
