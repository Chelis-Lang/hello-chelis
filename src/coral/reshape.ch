module Hello.Coral.Reshape
import Coral.Frame (Frame, Column, FloatCol, StringCol, from_pairs)
import Coral.Reshape (pivot, melt)
export (long_frame, wide_frame, pivoted, melted)
def long_frame() -> Frame[4] = from_pairs([("city", StringCol(["a", "a", "b", "b"])), ("product", StringCol(["x", "y", "x", "y"])), ("price", FloatCol(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32), cast(4.0, f32)])))])
def wide_frame() -> Frame[3] = from_pairs([("city", StringCol(["a", "b", "c"])), ("qty", FloatCol(to_tensor([cast(1.0, f32), cast(2.0, f32), cast(3.0, f32)]))), ("price", FloatCol(to_tensor([cast(10.0, f32), cast(20.0, f32), cast(30.0, f32)])))])
def pivoted() -> Frame[2] = pivot(long_frame(), "city", "product", "price")
def melted() -> Frame[6] = melt(wide_frame(), ["city"], ["qty", "price"])
