-- Quote an SVI slice at three log-strikes after choosing admissible parameters.
-- A fitted slice with a negative minimum is rejected by the screening API.
import Hello.Proofdemos.VolatilityScreen (volatility_report, screened_variance)
slice_volatilities = volatility_report()
negative_variance_fit = screened_variance(-1.0f32, 0.0f32, 0.0f32, 0.0f32, 0.2f32, 0.0f32)
