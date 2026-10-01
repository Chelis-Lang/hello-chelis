# `verify/` — full-lowering verification via the C backend

The IR evaluator that backs `chelis test` doesn't ship every primitive
on the pinned toolchain. These examples lower correctly through the
**C backend** (`chelis build --target c`) and execute against the
chelis runtime. The test harness builds, links, runs, and golden-diffs
every committed program in this directory so regressions are explicit.

This directory holds small, project-free Chelis programs that exercise
exactly the features the host runtime can't. Each one is built, linked
against `libchelis_runtime.a` + OpenBLAS, run, and the stdout is
diffed against a golden in `expected/`.

| Feature | Source | Golden |
|---|---|---|
| `grad` over a concrete tensor scalar reduction | [`grad_quadratic.ch`](grad_quadratic.ch) | [`expected/grad_quadratic.txt`](expected/grad_quadratic.txt) |
| `grad` through a wrapper function parameter | [`grad_works.ch`](grad_works.ch) | [`expected/grad_works.txt`](expected/grad_works.txt) |
| `cast` between precisions | [`cast_lowers.ch`](cast_lowers.ch) | [`expected/cast_lowers.txt`](expected/cast_lowers.txt) |
| `realize` forced evaluation | [`realize_lowers.ch`](realize_lowers.ch) | [`expected/realize_lowers.txt`](expected/realize_lowers.txt) |
| `relu` tensor lowering | [`relu_lowers.ch`](relu_lowers.ch) | [`expected/relu_lowers.txt`](expected/relu_lowers.txt) |
| `sigmoid` tensor lowering | [`sigmoid_lowers.ch`](sigmoid_lowers.ch) | [`expected/sigmoid_lowers.txt`](expected/sigmoid_lowers.txt) |
| activation chaining | [`relu_then_sigmoid.ch`](relu_then_sigmoid.ch) | [`expected/relu_then_sigmoid.txt`](expected/relu_then_sigmoid.txt) |

## Run them

The harness is [`tests/test_c_backend.py`](../tests/test_c_backend.py):

```sh
python3 -m pytest -q tests/test_c_backend.py
```

Each supported-lowering test:

1. Copies `verify/<name>.ch` to a temp dir so the C lane builds each
   verification program in isolation.
2. Runs `chelis build <name>.ch --output <tmp>/<name>`.
3. Links the emitted C with `gcc -fopenmp <name>.c -L<tmp>/<name>
   -lchelis_runtime -lopenblas -lm -lpthread -ldl`.
4. Runs the binary and diffs stdout against `expected/<name>.txt`.

## Add a new verification

Drop a `<name>.ch` here, build + run it once to produce
`expected/<name>.txt`, commit both. The harness picks up new pairs
automatically.

## Why a separate directory?

The C lane builds each verification program in isolation. A whole-package
C build still fails on the local-binding scalar gradients tracked by
chelis#2379. Giving these programs bare module names such as `GradWorks`
keeps them usable outside the teaching package.
