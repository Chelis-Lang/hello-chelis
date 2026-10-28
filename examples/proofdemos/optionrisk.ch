module Hello.Examples.Proofdemos.OptionRisk
-- Run from the hello-chelis repository root:
-- chelis eval --file examples/proofdemos/optionrisk.ch
-- Prove the guarded mathematical claims:
-- chelis prove examples/proofdemos/optionrisk.ch --tier smt-only --only smt_ --json
-- The per-option Greek bounds live in properties/blackscholes_greeks.ch.
-- With CHELIS_BEACON_BIN set, run their existing source-bound gate:
-- uv run --group test python tests/test_greek_properties.py
-- The counterexample_* claims below are deliberately false. Select them
-- with --tier smt-only --only counterexample_symbolic_; refutation exits 1.
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
-- The existing Greek certificates use these same fixed model inputs.
-- These scaling properties state the certified intervals as explicit guards.
@property smt_hedge_position_bounded forall(d: f32) where d >= 0.0f32, d <= 1.0f32:
  ((hedge_from_delta(d) >= 0.0f32) && (hedge_from_delta(d) <= 10.0f32))
@property smt_vega_position_bounded forall(v: f32) where v >= 0.0f32, v <= 42.0f32:
  ((notional_from_vega(v) >= 0.0f32) && (notional_from_vega(v) <= 420.0f32))
-- Concrete report: these top-level bindings are printed by chelis eval.
-- Single-call price, ten-call delta equivalent, and ten-call vega per unit
-- volatility. The four AD bounds cover every spot between 96 and 104.
option_risk_at_100 = option_report(100.0f32)
outside_certified_box = screened_report(120.0f32)
-- Deliberately false claims: inspect the assumptions they omit or reverse.
@property counterexample_symbolic_hedge_half_position forall(d: f32) where d >= 0.0f32, d <= 1.0f32:
  (hedge_from_delta(d) <= 5.0f32)
@property counterexample_symbolic_vega_tight_budget forall(v: f32) where v >= 0.0f32, v <= 42.0f32:
  (notional_from_vega(v) <= 400.0f32)
