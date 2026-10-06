# `verify/`: compiling to C

Small standalone programs that go through the C backend end to end:
`chelis build` turns each into C, the harness links it against
`libchelis_runtime.a` and OpenBLAS, runs the binary, and compares its output
with a golden file in `expected/`.

| Feature | Source | Golden |
|---|---|---|
| `grad` of a tensor sum of squares | [`grad_quadratic.ch`](grad_quadratic.ch) | [`expected/grad_quadratic.txt`](expected/grad_quadratic.txt) |
| `grad` through a function passed as a parameter | [`grad_works.ch`](grad_works.ch) | [`expected/grad_works.txt`](expected/grad_works.txt) |
| `cast` between precisions | [`cast_lowers.ch`](cast_lowers.ch) | [`expected/cast_lowers.txt`](expected/cast_lowers.txt) |
| `realize` forcing evaluation | [`realize_lowers.ch`](realize_lowers.ch) | [`expected/realize_lowers.txt`](expected/realize_lowers.txt) |
| tensor `relu` | [`relu_lowers.ch`](relu_lowers.ch) | [`expected/relu_lowers.txt`](expected/relu_lowers.txt) |
| tensor `sigmoid` | [`sigmoid_lowers.ch`](sigmoid_lowers.ch) | [`expected/sigmoid_lowers.txt`](expected/sigmoid_lowers.txt) |
| `relu` then `sigmoid` | [`relu_then_sigmoid.ch`](relu_then_sigmoid.ch) | [`expected/relu_then_sigmoid.txt`](expected/relu_then_sigmoid.txt) |

## Run them

```sh
uv run --group test pytest -q tests/test_c_backend.py
```

For each program, [`tests/test_c_backend.py`](../tests/test_c_backend.py):

1. copies `verify/<name>.ch` to a temporary directory;
2. runs `chelis build <name>.ch --output <tmp>/<name>`;
3. links with `gcc -fopenmp <name>.c -L<tmp>/<name> -lchelis_runtime
   -lopenblas -lm -lpthread -ldl`;
4. runs the binary and compares its output with `expected/<name>.txt`.

## Why these live outside `src/`

`verify/` is not a source root of the package, and each file is a standalone
module (`module GradWorks`, not `module Hello.*`), so it is compiled on
its own. The package's Black-Scholes Greeks have a separate compiled test.

## Add one

Add a standalone `<name>.ch` here, build and run it once, save its output
as `expected/<name>.txt`, and commit both. The harness finds it
automatically.
