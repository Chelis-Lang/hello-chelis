module Hello.Coral.FrameBasics
import Coral.Frame (Frame, Column, FloatCol, StringCol, from_pairs, nrows, ncols, columns, with_column, rename, drop_column, int_col_of_list)
export (build_frame, add_score_col, frame_after_rename, frame_after_drop)
def build_frame() -> Frame[3] = from_pairs([("price", FloatCol(to_tensor([10.0f32, 20.0f32, 30.0f32]))), ("qty", int_col_of_list([1i64, 2i64, 3i64])), ("city", StringCol(["paris", "oslo", "berlin"]))])
def add_score_col(df: Frame[3]) -> Frame[3] = with_column(df, "score", FloatCol(to_tensor([0.5f32, 0.75f32, 0.9f32])))
def frame_after_rename(df: Frame[3]) -> Frame[3] = rename(df, "city", "town")
def frame_after_drop(df: Frame[3]) -> Frame[3] = drop_column(df, "qty")
