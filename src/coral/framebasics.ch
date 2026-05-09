module Hello.Coral.FrameBasics
import Coral.Frame (Frame, Column, from_pairs, nrows, ncols, columns, with_column, rename, drop_column, int_col_of_list)
export (build_frame, add_score_col, frame_after_rename, frame_after_drop)
def build_frame() -> Frame[3] = { from_pairs([("price", FloatCol(to_tensor([cast(10.0, f32), cast(20.0, f32), cast(30.0, f32)]))), ("qty", int_col_of_list([cast(1, int64), cast(2, int64), cast(3, int64)])), ("city", StringCol(["paris", "oslo", "berlin"]))]) }
def add_score_col(df: Frame[3]) -> Frame[3] = { df
|> with_column("score", FloatCol(to_tensor([cast(0.5, f32), cast(0.75, f32), cast(0.9, f32)]))) }
def frame_after_rename(df: Frame[3]) -> Frame[3] = rename(df, "city", "town")
def frame_after_drop(df: Frame[3]) -> Frame[3] = drop_column(df, "qty")
