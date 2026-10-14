module Hello.Proofdemos.OptionRisk
import Hello.Capstone.BlackScholes (call_price, delta, vega)
export (report_delta, report_vega, hedge_from_delta, notional_from_vega, option_report, screened_report)
-- This report holds strike 100, rate 5%, volatility 20%, maturity one year,
-- and ten calls. Delta and vega are grad of the actual capstone price, whose
-- normal CDF comes from Nautilus. No textbook Greek replaces that AD graph.
def report_delta(s: f32) -> f32 = delta(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
def report_vega(s: f32) -> f32 = vega(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32)
-- These scalar adapters make proof composition visible: once the per-option
-- Greek lies in its interval, an SMT claim bounds a ten-option position.
def hedge_from_delta(d: f32) -> f32 = (10.0f32 * d)
def notional_from_vega(v: f32) -> f32 = (10.0f32 * v)
-- Shares are the long position's delta equivalent. Hedging it requires the
-- opposite position. Vega is per unit volatility: multiply by 0.01 for a
-- first-order one-percentage-point scenario. That is a sensitivity estimate,
-- not a certified bound on the nonlinear repricing error for a finite shock.
def option_report(s: f32) -> (f32, f32, f32) = (call_price(s, 100.0f32, 0.05f32, 0.2f32, 1.0f32), hedge_from_delta(report_delta(s)), notional_from_vega(report_vega(s)))
def screened_report(s: f32) -> Option[(f32, f32, f32)] = if ((s >= 96.0f32) && (s <= 104.0f32)) then Some(option_report(s)) else None
-- Beacon proves all four bounds across the whole spot box. Changing another
-- model input changes the proof target and requires a new certificate.
@property beacon_report_delta_lower forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (report_delta(s) >= 0.0f32)
@property beacon_report_delta_upper forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (report_delta(s) <= 1.0f32)
@property beacon_report_vega_lower forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (report_vega(s) >= 0.0f32)
@property beacon_report_vega_upper forall(s: f32) where s >= 96.0f32, s <= 104.0f32:
  (report_vega(s) <= 42.0f32)
@property smt_hedge_position_bounded forall(d: f32) where d >= 0.0f32, d <= 1.0f32:
  ((hedge_from_delta(d) >= 0.0f32) && (hedge_from_delta(d) <= 10.0f32))
@property smt_vega_position_bounded forall(v: f32) where v >= 0.0f32, v <= 42.0f32:
  ((notional_from_vega(v) >= 0.0f32) && (notional_from_vega(v) <= 420.0f32))
