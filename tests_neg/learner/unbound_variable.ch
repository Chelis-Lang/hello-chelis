-- GENERATED from tests/negative/unbound_variable.ch; run python3 scripts/sync_negative_tests.py
module Hello.TestsNeg.Learner.Unbound_Variable
-- chelis-expect-fail: UnboundVariable
def bad(x: tensor[n, f32]) -> tensor[n, f32] = missing(x)
def test_neg_unbound_variable() -> unit = test_assert(false, "unbound_variable unexpectedly compiled")
