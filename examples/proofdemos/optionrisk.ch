-- Single-call price, ten-call delta equivalent, and ten-call vega per unit
-- volatility. The four AD bounds cover every spot between 96 and 104.
import Hello.Proofdemos.OptionRisk (option_report, screened_report)
option_risk_at_100 = option_report(100.0f32)
outside_certified_box = screened_report(120.0f32)
