# Upstream Bugs

Track suspected Chelis and shell-package bugs here. Every current entry records
its exact pin, command-surface verdicts, executable evidence, workaround, and
re-probe trigger. File Chelis defects as `chelis#NNN`; use a parked issue draft
only until the root cause is isolated enough to file.

## Actively blocking

### Black-Scholes grad through `normal_cdf` — issue draft

- **Pin:** Chelis `0.16.1`, Nautilus `0.7.34`.
- **Source:** `docs/issue_drafts/blackscholes_grad_bool_condition.md`.
- **Per verb:** `check` PASS; native `test` BLOCKED with `if condition must be bool, got Tensor(...)`; Reef build PASS; C source generation PASS but no accepted exact-value runtime oracle.
- **Evidence:** `tests_blocked/capstone/blackscholes_grad.ch`.
- **Workaround:** teach `call_price`; keep `delta`/`vega` visible but do not claim native execution.
- **Re-probe trigger:** the issue draft is filed/resolved or grad/conditional lowering changes.

### Narrow-float C host boundaries — `chelis#716`

- **Pin:** Chelis `0.16.1`.
- **Per verb:** `check` PASS; `eval` PASS for exactly representable bf16 values; Reef build PASS; generated C compiles but prints `[2.003875732421875, 0.0]` for the bf16 cast of `[1.0, 2.0]`.
- **Evidence:** R11 in the OpenSpec reprobe evidence and the manual command in `tests_blocked/README.md`.
- **Workaround:** learner examples remain f32/f64 across C boundaries.
- **Re-probe trigger:** a release closing `chelis#716`; require byte-correct C output before promotion.

## Tracking

### Coral Parquet stub

- **Pin:** Coral `0.7.31` on Chelis `0.16.1`.
- **Source:** `Chelis-Lang/coral@v0.7.31:src/io.ch:203`.
- **Per verb:** `check` PASS; native eval/test BLOCKED; Reef/C generation PASS; C execution fails with the same explicit message.
- **Evidence:** `tests_blocked/coral/parquet.ch`.
- **Disposition:** this is an explicit Coral capability stub, not an inferred Chelis regression.
- **Re-probe trigger:** a Coral release replacing `fail(...)` with an executable Parquet implementation.

## Parked

- `chelis check <directory>` no longer emits the historical immediate argument error, but `<FILE>` remains the documented command contract and the directory probe did not terminate within 30 minutes. Per-file checks remain guidance, not an upstream bug claim.

## Archived

### Resolved by the 0.16.1 reprobe

Direct tensor/scalar grad, C direct-grad lowering, `realize`, `vmap`, activation
host execution, piped activation C output, seeded C projects, `expand` shape
agreement, nested numeric `to_tensor`, and higher-order scalar/tensor C wrappers
all passed their required evaluator and C execution probes. Their old v0.8.0
workarounds are removed rather than preserved as historical compatibility code.

`copy(scalar)` remains a deliberate type error (`copy` is tensor-only), not an
upstream limitation.
