module Hello.Coral.AdThroughDataFrame

import Coral.Frame (Frame, Column, from_pairs, nrows)

export (frame_shape_check, simple_loss, dsimple_loss_dw)

-- Frame construction itself works (purely structural, no autodiff).
-- This shows we CAN build a Coral.Frame from a parameter-derived tensor
-- and inspect its shape.
def frame_shape_check(w: tensor[n, f32]) -> int64 = {
  df = from_pairs([("w", FloatCol(w))])
  nrows(df)
}

-- Autodiff path: a scalar-output loss whose backward returns a tensor.
-- The chelis 0.6.1 evaluator does not currently lower `grad` through the
-- Frame ADT, so we keep the differentiable expression on raw tensors.
-- Loss = sum(w * w); d/dw = 2 * w.
def simple_loss(w: tensor[n, f32]) -> tensor[f32] = {
  prod = mul(copy(w), w)
  sum(prod, 0)
}

def dsimple_loss_dw(w: tensor[n, f32]) -> tensor[n, f32] = grad(simple_loss, wrt=w)(w)
