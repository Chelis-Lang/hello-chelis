-- Compare two growth scenarios and the value less an 18-unit market price.
import Hello.Proofdemos.GrowthScreen (valuation_report, screened_value)
growth_scenarios = valuation_report()
invalid_spread = screened_value(1.0f32, 0.03f32, 0.08f32)
