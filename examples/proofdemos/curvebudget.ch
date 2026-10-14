-- These are samples of an allocation curve whose entire segment is bounded.
import Hello.Proofdemos.CurveBudget (allocation_report, planned_spend_checked)
checkpoint_spending = allocation_report()
outside_segment = planned_spend_checked(1.5f32)
