# `verify/` — full-lowering verification via the C backend

The IR evaluator that backs `chelis test` doesn't ship every primitive
on v0.6.1. `grad`, `realize`, tensor `relu`/`sigmoid`, and tensor `cast`
all lower correctly through the **C backend** (`chelis build --target
c`) and execute against the chelis runtime — and that's the production
path anyway.

This directory holds small, project-free Chelis programs that exercise
exactly the features the host runtime can't. Each one is built, linked
against `libchelis_runtime.a` + OpenBLAS, run, and the stdout is
diffed against a golden in `expected/`.

| Feature | Source | Golden |
|---|---|---|
| `grad` over a tensor scalar reduction | [`grad_works.ch`](grad_works.ch) | [`expected/grad_works.txt`](expected/grad_works.txt) |
| Tensor `relu` activation | [`relu_lowers.ch`](relu_lowers.ch) | [`expected/relu_lowers.txt`](expected/relu_lowers.txt) |
| Tensor `sigmoid` activation | [`sigmoid_lowers.ch`](sigmoid_lowers.ch) | [`expected/sigmoid_lowers.txt`](expected/sigmoid_lowers.txt) |
| `cast` between precisions | [`cast_lowers.ch`](cast_lowers.ch) | [`expected/cast_lowers.txt`](expected/cast_lowers.txt) |
| `realize` forced evaluation | [`realize_lowers.ch`](realize_lowers.ch) | [`expected/realize_lowers.txt`](expected/realize_lowers.txt) |

## Run them

The harness is [`tests/test_c_backend.py`](../tests/test_c_backend.py):

```sh
python3 -m pytest -q tests/test_c_backend.py
```

Each test:

1. Copies `verify/<name>.ch` to a temp dir (so `chelis build` doesn't
   pull in the rest of the project — Reef projects with `with seed(...)`
   anywhere in `src/` are rejected by the C backend).
2. Runs `chelis build <name>.ch --output <tmp>/<name>`.
3. Links the emitted C with `gcc -fopenmp <name>.c -L<tmp>/<name>
   -lchelis_runtime -lopenblas -lm -lpthread -ldl`.
4. Runs the binary and diffs stdout against `expected/<name>.txt`.

## Add a new verification

Drop a `<name>.ch` here, build + run it once to produce
`expected/<name>.txt`, commit both. The harness picks up new pairs
automatically.

## Why a separate directory?

`chelis build` rejects any project source tree containing `with
seed(...)` because the C backend doesn't yet plumb the seeded RNG.
`src/basics/effectsrandom.ch` uses `with seed(42)`, which trips the
gate for the whole project. Putting verification programs outside
`src/` (and giving them bare module names like `module GradWorks`
instead of `module Hello.*`) sidesteps the gate without sacrificing
coverage of the `src/` corpus.
