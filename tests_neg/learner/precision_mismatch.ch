-- GENERATED from tests/negative/precision_mismatch.ch; run python3 scripts/sync_negative_tests.py
module Hello.TestsNeg.Learner.Precision_Mismatch
-- chelis-expect-fail: PrecisionMismatch
def bad(x: tensor[n, f32], y: tensor[n, f64]) -> tensor[n, f32] = add(x, y)
def test_neg_precision_mismatch() -> unit = test_assert(false, "precision_mismatch unexpectedly compiled")
