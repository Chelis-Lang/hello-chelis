module Hello.Tests.Proofdemos.CurveBudget
import Hello.Proofdemos.CurveBudget (planned_spend, planned_spend_checked)
import Std.Test (assert_close, assert_true)
def test_spend_schedule() -> unit ! { Test } = {
  _ = assert_close(planned_spend(0.0f32), 250.0f32, 0.001f32, "initial allocation")
  _ = assert_close(planned_spend(0.25f32), 328.125f32, 0.001f32, "curved schedule at the quarter checkpoint")
  _ = assert_close(planned_spend(0.5f32), 500.0f32, 0.001f32, "middle allocation")
  assert_close(planned_spend(1.0f32), 750.0f32, 0.001f32, "final allocation")
}
def test_reject_extrapolation() -> unit ! { Test } = {
  rejected = match planned_spend_checked(1.5f32) with {
    | None => true
    | Some(_) => false
  }
  assert_true(rejected, "the segment proof supplies no extrapolation bound")
}
def test_accept_segment_input() -> unit ! { Test } = {
  admitted = match planned_spend_checked(0.5f32) with {
    | Some(v) => (v == 500.0f32)
    | None => false
  }
  assert_true(admitted, "accept the middle of the allocation segment")
}
