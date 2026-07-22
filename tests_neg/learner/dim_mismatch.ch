-- GENERATED from tests/negative/dim_mismatch.ch; run python3 scripts/sync_negative_tests.py
module Hello.TestsNeg.Learner.Dim_Mismatch
-- chelis-expect-fail: DimensionMismatch
def bad(x: tensor[batch, f32], y: tensor[seq, f32]) -> tensor[batch, f32] = add(x, y)
def test_neg_dim_mismatch() -> unit = test_assert(false, "dim_mismatch unexpectedly compiled")
