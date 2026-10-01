module Hello.Coral.Reshape
import Coral.Frame (Frame, Column, FloatCol, StringCol, from_pairs)
import Coral.Reshape (pivot, melt)
export (long_frame, wide_frame, pivoted, melted)
def long_frame() -> Frame[4] = from_pairs([("city", StringCol(["a", "a", "b", "b"])), ("product", StringCol(["x", "y", "x", "y"])), ("price", FloatCol(to_tensor([1.0f32, 2.0f32, 3.0f32, 4.0f32])))])
def wide_frame() -> Frame[3] = from_pairs([("city", StringCol(["a", "b", "c"])), ("qty", FloatCol(to_tensor([1.0f32, 2.0f32, 3.0f32]))), ("price", FloatCol(to_tensor([10.0f32, 20.0f32, 30.0f32])))])
def pivoted() -> Frame[2] = pivot(long_frame(), "city", "product", "price")
def melted() -> Frame[6] = melt(wide_frame(), ["city"], ["qty", "price"])
