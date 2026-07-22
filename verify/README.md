# `verify/` — C-backend execution goldens

These focused, project-free programs prove that selected Chelis surfaces generate
C, compile against `libchelis_runtime.a` + OpenBLAS, execute, and preserve their
committed stdout. On Chelis `0.16.1`, most also run in the evaluator; this lane
remains valuable as an independent production-backend oracle.

| Feature | Source | Golden |
|---|---|---|
| direct `grad` over a tensor reduction | [`grad_quadratic.ch`](grad_quadratic.ch) | [`expected/grad_quadratic.txt`](expected/grad_quadratic.txt) |
| direct multi-argument `grad` | [`grad_works.ch`](grad_works.ch) | [`expected/grad_works.txt`](expected/grad_works.txt) |
| f32/f64 cast | [`cast_lowers.ch`](cast_lowers.ch) | [`expected/cast_lowers.txt`](expected/cast_lowers.txt) |
| `realize` | [`realize_lowers.ch`](realize_lowers.ch) | [`expected/realize_lowers.txt`](expected/realize_lowers.txt) |
| `relu` | [`relu_lowers.ch`](relu_lowers.ch) | [`expected/relu_lowers.txt`](expected/relu_lowers.txt) |
| `sigmoid` | [`sigmoid_lowers.ch`](sigmoid_lowers.ch) | [`expected/sigmoid_lowers.txt`](expected/sigmoid_lowers.txt) |
| activation chaining | [`relu_then_sigmoid.ch`](relu_then_sigmoid.ch) | [`expected/relu_then_sigmoid.txt`](expected/relu_then_sigmoid.txt) |

## Run them

```sh
python3 -m pytest -q tests/test_c_backend.py
```

For each pair the harness:

1. copies one `verify/<name>.ch` into a temporary standalone root;
2. runs `chelis build <name>.ch --output <tmp>/<name>`;
3. compiles the emitted C with GCC, OpenMP, OpenBLAS, and the emitted runtime;
4. runs the binary and byte-compares stdout with `expected/<name>.txt`.

The temporary root keeps each result focused and avoids rebuilding the complete
learner package seven times. It is no longer a workaround for seeded source:
`with seed(...)` now generates and executes through C at the `0.16.1` pin.

## Add a verification

Add `verify/<name>.ch`, run and review its generated binary once, then record the
accepted stdout in `verify/expected/<name>.txt`. Regenerate its Deep sibling only
through `python3 scripts/regen_deep.py`.
