module Hello.Tests.Coral.FrameBasics
import Hello.Coral.FrameBasics (build_frame, add_score_col, frame_after_rename, frame_after_drop)
import Coral.Frame (nrows, ncols, columns)
import Std.Test (assert_eq, assert_true)
def test_build_frame_shape() -> unit ! { Test } = {
  df = build_frame()
  _ = assert_eq(nrows(df), 3i64, "build_frame nrows == 3")
  assert_eq(ncols(df), 3i64, "build_frame ncols == 3")
}
def test_with_column_grows_ncols() -> unit ! { Test } = {
  df2 = add_score_col(build_frame())
  _ = assert_eq(nrows(df2), 3i64, "after with_column nrows still 3")
  assert_eq(ncols(df2), 4i64, "after with_column ncols == 4")
}
def test_rename_and_drop() -> unit ! { Test } = {
  renamed = frame_after_rename(build_frame())
  dropped = frame_after_drop(build_frame())
  names_r = columns(renamed)
  has_town = fold(fn (acc: bool, n: string) -> or(acc, eq(n, "town")), false, names_r)
  _ = assert_true(has_town, "renamed frame contains 'town'")
  _ = assert_eq(ncols(renamed), 3i64, "rename keeps 3 cols")
  assert_eq(ncols(dropped), 2i64, "drop_column qty -> 2 cols")
}
