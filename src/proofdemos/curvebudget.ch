module Hello.Proofdemos.CurveBudget
import Nautilus.Interpolation (cubic_hermite)
export (allocation_weight, spend_from_weight, planned_spend, planned_spend_checked, allocation_report)
-- A staged project allocates 25% of a budget at the first checkpoint and 75%
-- at the last. A Hermite segment fills in intermediate allocation weights.
-- Both endpoint slopes are zero, so spending eases into each checkpoint.
-- Zero lies between zero and three times the secant slope, satisfying the
-- sufficient nonovershoot bounds used by Nautilus. The segment is curved.
-- The binary-exact fractions keep the teaching arithmetic easy to inspect.
def allocation_weight(t: f32) -> f32 = cubic_hermite(0.0f32, 1.0f32, 0.25f32, 0.75f32, 0.0f32, 0.0f32, t)
-- The scaling theorem states its input interval as an explicit guard. This
-- makes the connection between interpolation and budget easy to inspect;
-- chelis prove does not automatically chain these certificates.
def spend_from_weight(weight: f32) -> f32 = (1000.0f32 * weight)
def planned_spend(t: f32) -> f32 = spend_from_weight(allocation_weight(t))
-- A proof guard does not insert a runtime check. The data-facing entry point
-- spells out the same segment domain and signals rejection with None.
def planned_spend_checked(t: f32) -> Option[f32] = if ((t >= 0.0f32) && (t <= 1.0f32)) then Some(planned_spend(t)) else None
def allocation_report() -> (f32, f32, f32) = (planned_spend(0.0f32), planned_spend(0.25f32), planned_spend(1.0f32))
-- These are statements about the whole continuous interval, not just the
-- three checkpoints printed by allocation_report. They say nothing about
-- extrapolation outside [0, 1] or arbitrary changes to the endpoint slopes.
@property smt_allocation_lower forall(t: f32) where t >= 0.0f32, t <= 1.0f32:
  (allocation_weight(t) >= 0.25f32)
@property smt_allocation_upper forall(t: f32) where t >= 0.0f32, t <= 1.0f32:
  (allocation_weight(t) <= 0.75f32)
@property smt_spend_lower forall(weight: f32) where weight >= 0.25f32, weight <= 0.75f32:
  (spend_from_weight(weight) >= 250.0f32)
@property smt_spend_upper forall(weight: f32) where weight >= 0.25f32, weight <= 0.75f32:
  (spend_from_weight(weight) <= 750.0f32)
