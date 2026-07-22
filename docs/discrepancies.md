# Compiler and Runtime Discrepancies (Chelis 0.16.1)

Chelis exposes a shared front end through three execution surfaces:

- **Front end:** `chelis check <file>`
- **IR evaluator:** `chelis eval --file <file>` and `chelis test`
- **C backend:** `chelis build --target c <file>`, followed by C compilation

A claim is current only after its relevant surfaces are executed. The complete
0.16.1 reprobe matrix is retained in the active OpenSpec change evidence; this
document carries only limitations that survived.

## Current limitations

### Black-Scholes grad through `normal_cdf`

`grad` itself works for direct scalar and tensor losses in both evaluator and C
lanes. The real Black-Scholes `delta`/`vega` graph still fails native evaluation:

```text
if condition must be bool, got Tensor(RuntimeTensorValue { ... precision: Bool })
```

- `check`: PASS
- native `test`: BLOCKED
- Reef build: PASS
- C generation: PASS, but no accepted exact-value runtime oracle for this graph
- executable probe: `tests_blocked/capstone/blackscholes_grad.ch`
- source: `docs/issue_drafts/blackscholes_grad_bool_condition.md`

Teach and execute `call_price`; retain the Greeks as visible blocked capability
until both delta and vega exact-value assertions pass.

### bf16/f16 C host boundaries (`chelis#716`)

Tensor f32→bf16 casts check and evaluate, and their C kernels are generated. The
C host-boundary printer still reads 2-byte narrow-float buffers as f32. Casting
`[1.0, 2.0]` to bf16 therefore compiles but prints:

```text
[2.003875732421875, 0.0]
```

Learner-facing C examples remain f32/f64. See the manual reprobe in
`tests_blocked/README.md`; do not promote bf16 C output until the emitted binary
is byte-correct.

### Coral Parquet is an explicit package stub

Coral `0.7.31` implements `read_parquet_frame` and `write_parquet_frame` as
explicit `fail(...)` calls (`Chelis-Lang/coral@v0.7.31:src/io.ch:203`). The API
checks and generates C, but evaluator and C execution fail with:

```text
read_parquet_frame requires Std.Io.Parquet (not in current runtime)
```

Executable probe: `tests_blocked/coral/parquet.ch`. CSV and JSON frame I/O are
fully executable at the pin.

## Command-contract guidance

`chelis check --help` documents a single `<FILE>`. A directory argument no
longer produces the old immediate argument error, but it did not terminate in a
30-minute image probe. CI uses explicit file checks plus `chelis reef build`;
do not treat directory checking as an acceptance oracle.

## Resolved during the 0.16.1 bump

| Historical claim | 0.16.1 evidence |
|---|---|
| direct `grad` unavailable in evaluator | scalar and tensor direct-grad eval/C probes pass |
| direct grad rejected by C, requiring wrapper form | direct and wrapper C binaries both pass; verify fixtures now use direct grad |
| `realize` unavailable in evaluator | native assertion and C golden pass |
| `vmap` restricted | batched native assertion and C probe pass |
| tensor activations unavailable in evaluator | piped `relu`→`sigmoid` native assertion passes |
| piped activations lose C shape | piped/direct C output is identical |
| `with seed(...)` blocks project C generation | package-context evaluator and C binary both pass |
| `expand` check/runtime shape divergence | both lanes produce `[64,1]` in the LinReg path |
| nested numeric `to_tensor` rejected | `[2,2]` eval and C probes pass |
| higher-order scalar wrappers omitted in C | scalar and tensor wrapper binaries pass |
| fixed-shape symbolic-dim C panic | current C golden suite passes |

`copy(scalar)` remains a deliberate type error because scalar values are not
linear resources. It is not an upstream limitation.

## Evidence lanes

| Invariant | Command |
|---|---|
| package front end | `chelis reef build` |
| native runtime | `chelis test tests/ --jobs auto` |
| must-reject diagnostics | `chelis test tests_neg/ --expect neg` |
| expected upstream blockers | `chelis test tests_blocked/ --expect blocked` |
| Deep source drift | `python3 scripts/regen_deep.py --check` |
| C generation/link/runtime | `python3 -m pytest -q tests/test_c_backend.py` |
| Octant round trips | `python3 -m pytest -q tests/test_octant_pairs.py` |
| c-earchin proof diagnostics | `python3 -m pytest -q tests/test_c_earchin_artifacts.py` |
