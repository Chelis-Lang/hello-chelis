# Calculations with explicit bounds

These six programs combine numerical libraries, small application policies,
and properties on the functions the programs actually call. Each runnable
file contains its imports, calculation, commentary, `@property` obligations,
and report invocation. Read and run the same file; the implementations live
here.

Start in a hello-chelis checkout containing these examples, with its pinned
compiler on `PATH`. Paths below are relative to that repository, so first
change to the hello-chelis directory (the Chelis compiler checkout is a
separate repository). Install the locked published dependencies, then run a
program:

```sh
chelis reef install --from-lockfile
chelis eval --file examples/proofdemos/probabilitybudget.ch
chelis eval --file examples/proofdemos/curvebudget.ch
chelis eval --file examples/proofdemos/collateralbudget.ch
chelis eval --file examples/proofdemos/growthscreen.ch
chelis eval --file examples/proofdemos/optionrisk.ch
chelis eval --file examples/proofdemos/volatilityscreen.ch
```

For the collateral example, evaluation prints the bond mark, unsecured
exposure after the haircut, and the illustrative capital buffer:

```text
collateral.0 = 1018.5941
collateral.1 = 233.71881
collateral.2 = 29.214851
```

`eval` executes the report; it does not prove its properties. To check its
five guarded mathematical claims, use:

```sh
chelis prove examples/proofdemos/collateralbudget.ch --tier smt-only --only smt_ --json
```

Successful proof records say `"status":"passed"`, and the command exits zero.
To execute the runtime assertions for the same functions, use:

```sh
chelis test tests/proofdemos/collateralbudget.ch --jobs auto
```

| Program | Calculation and property |
|---|---|
| [Probability budget](probabilitybudget.ch) | Nautilus CDFs turn trigger thresholds into expected payouts. The uniform model's expectation is between zero and the maximum payout for every threshold and every nonempty support interval. The standard-normal model's 1000-unit reserve is bounded on standardized thresholds `[-2, 2]`. |
| [Allocation curve](curvebudget.ch) | Nautilus cubic Hermite interpolation fills in an allocation schedule between two checkpoints. The weight stays in `[0.25, 0.75]` throughout the segment, so the planned spending stays in `[250, 750]`. The checked entry point rejects extrapolation. |
| [Collateral budget](collateralbudget.ch) | Shoals marks a two-period bond, applies a CSA, and reserves one eighth of the unsecured exposure. A higher coupon raises the mark at fixed nonnegative yield; residual exposure is between zero and the original positive exposure; larger haircuts cannot reduce it; the reserve stays within the stated policy ceiling. |
| [Growth screen](growthscreen.ch) | Economoist values a growing dividend and compares it with a market price. Increasing growth raises both valuation and the purchase margin when both discount spreads are positive. A finite input box gives a valuation in `[6, 26]`; the screened API admits that box and returns `None` otherwise. |
| [Option risk](optionrisk.ch) | The capstone's actual differentiated Black-Scholes implementation supplies a ten-call position's delta equivalent and vega. The existing [Greek certificates](../../properties/blackscholes_greeks.ch) bound per-option `delta` in `[0, 1]` and `vega` in `[0, 42]` on spot `[96, 104]`. Separate scalar SMT properties turn those intervals into position bounds `[0, 10]` and `[0, 420]`. |
| [Volatility screen](volatilityscreen.ch) | Shoals raw SVI supplies a volatility smile at three log-strikes. A parameter screen checks the minimum-variance condition before a quote uses variance in a square root. The SMT theorem covers nonnegative variance at every log-strike under that condition. |

The datasets and policies are deliberately small and fixed. A payout
expectation is not a realized-loss limit. The collateral reserve fraction is
an illustrative policy. The growth calculation concerns Gordon's closed
form, and the SVI condition establishes variance nonnegativity rather than
absence of every form of static arbitrage.

## Read the proof domains

The uniform payout, allocation, CSA, coupon, Gordon, SVI, and position-scaling
properties use SMT. Run the exact authored obligations with no sampling:

```sh
chelis prove examples/proofdemos/probabilitybudget.ch --tier smt-only --only smt_ --json
chelis prove examples/proofdemos/curvebudget.ch --tier smt-only --only smt_ --json
chelis prove examples/proofdemos/collateralbudget.ch --tier smt-only --only smt_ --json
chelis prove examples/proofdemos/growthscreen.ch --tier smt-only --only smt_ --json
chelis prove examples/proofdemos/optionrisk.ch --tier smt-only --only smt_ --json
chelis prove examples/proofdemos/volatilityscreen.ch --tier smt-only --only smt_ --json
```

For example, the coupon comparison allows every nonnegative yield and every
ordered nonnegative coupon pair. The SVI claim allows every `k` and `m`, with
`b >= 0`, `sigma > 0`, `-1 < rho < 1`, and
`a + b*sigma*sqrt(1-rho*rho) >= 0`. These are guarded universal statements.
The allocation schedule instead proves one chosen Hermite segment at every
`t` in `[0, 1]`; it does not certify arbitrary endpoint slopes.

The normal-reserve bounds use Beacon's certified interval route. The
option report reuses the capstone's existing Greek properties and proof
harness. Set `CHELIS_BEACON_BIN` to a verified Beacon 0.1.22 binary:

```sh
export CHELIS_BEACON_BIN=/path/to/chelis-beacon
chelis prove examples/proofdemos/probabilitybudget.ch --tier beacon-only --only beacon_ --json
uv run --group test python tests/test_proof_demos.py
uv run --group test python tests/test_greek_properties.py
```

The option inputs are strike `100`, rate `0.05`, volatility `0.2`, and time
`1`; only spot varies over `[96, 104]`. The proof follows the exported
`grad` functions and Nautilus's actual normal CDF implementation. It does
not replace them with textbook delta or vega formulas. The gate requires a
complete strict Arb cover of the entire input interval, the exact goal and
input box, and compiler dependency edges reaching the imported CDF.

The report's vega is per **unit** volatility. Multiplying it by `0.01`
gives a first-order estimate for a one-percentage-point volatility change.
The derivative bound alone is not a bound on finite-shock repricing error.
The position-scaling SMT properties take the Greek intervals as explicit
guards; the spending adapter similarly takes the interpolation interval.
They do not automatically consume another property's certificate. The SVI
theorem calls Shoals' export directly with the same record as the example's
wrapper, which is the formulation supported by the released SMT lane.

All these numerical proof results use the **real interpretation of the
source expression**, including its stored constants. They do not establish
IEEE floating-point roundoff bounds. The execution tests exercise rounded
`f32` values at concrete inputs and serve a separate purpose.

## Try a claim that fails

Each program also contains deliberately false `counterexample_*` properties.
They omit a domain condition, reverse a monotonicity claim, or demand an
unjustifiably tight ceiling. Select those separately from the true claims:

```sh
chelis prove examples/proofdemos/collateralbudget.ch --tier smt-only --only counterexample_symbolic_ --json
chelis prove examples/proofdemos/probabilitybudget.ch --tier beacon-only --only counterexample_interval_ --json
```

These commands are expected to exit with status **1**, with `"status":"failed"`
records containing counterexamples. The six files contain eight symbolic
false claims in total, selected with `--only counterexample_symbolic_` and
`--tier smt-only`. The normal-reserve interval false claim requires a checked Arb point
witness. The existing Greek gate checks its own two false controls. Run the explicit selectors above: proving every property in a
lesson includes its intentionally false claims and therefore fails. A
successful evaluation is not evidence that those stronger claims hold.

The `where` clause restricts a proof; it does not insert runtime validation.
The allocation, growth, option, and SVI examples therefore show separate
screened entry points returning `Option`. Their checks implement the stated
admission rules; they are not general guarantees against nonfinite inputs,
overflow, or rounding at a boundary.

## Validation

```sh
chelis test tests/proofdemos --jobs auto
uv run --group test pytest -q tests/test_proof_demos.py
```

The ordinary Docker corpus runs the execution tests, all 18 positive SMT
claims, the eight SMT counterexamples, and Surf/Deep drift checks. The
explicit Beacon script is a separate acceptance command because the
ordinary Docker image does not install Beacon. It requires two certified
normal-reserve box bounds and one checked false control, with no unknown
results. The separate existing Greek gate requires four certified bounds
and two checked false controls.
