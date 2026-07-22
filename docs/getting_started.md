# Getting started

If you want a guided reading path through the corpus once it's
running, see [`curriculum.md`](curriculum.md). This page is just
install + first commands.

## 1. Build the image

```sh
git clone https://github.com/Chelis-Lang/hello-chelis.git
cd hello-chelis
export GITHUB_TOKEN=$(gh auth token)
docker compose -f docker/docker-compose.yml build
```

The image is `ubuntu:24.04` plus:

- GCC, OpenBLAS, libgomp, valgrind (for the C backend)
- Python 3 + pip (CI installs pytest before running the fallback harness)
- The `chelis` and `octant` CLIs from prebuilt release tarballs
- `libchelis_runtime.a` installed at `/usr/local/lib/`
- Chelis `0.16.1`, bundled `chelis-std` `0.4.0`, Coral `0.7.31`,
  Nautilus `0.7.34`, and School `0.1.10`
- The standalone Octant `0.10.1` translator; c-earchin proof fixtures are
  committed and need no package install

First build requires `GITHUB_TOKEN` access to the private Chelis-Lang
repos and downloads release artifacts instead of compiling toolchains
from source. Rebuilds reuse the layer cache.

On Apple Silicon with Apple Container:

```sh
GITHUB_TOKEN=$(gh auth token) container build --platform linux/amd64 \
  --file docker/Dockerfile --secret id=github_token,env=GITHUB_TOKEN \
  --tag hello-chelis:0.16.1 .
container run --rm --platform linux/amd64 --rosetta \
  --volume "$PWD:/workspace" --workdir /workspace hello-chelis:0.16.1
```

The `linux/amd64` platform is required because the authenticated release
tarballs currently contain x86-64 binaries. For the full `--jobs auto` native
suite, give the VM an explicit resource envelope (validated with
`container run --cpus 8 --memory 16G ...`) to avoid a low-default-memory kill.

## 2. Inside the container

```sh
docker compose -f docker/docker-compose.yml run --rm hello-chelis
```

Your repo checkout is mounted at `/workspace`. Everything below runs
from there.

## 3. The front-end gate — `chelis check`

```sh
chelis check src/basics/hellotensor.ch     # parse + types + dim
                                            # + effect + linearity
```

A file under the Reef root resolves against the complete pinned package graph.
`check --help` documents one `<FILE>`; use `chelis reef build` for the package
front-end gate rather than relying on directory-check behavior.

The full native test tree is blocking. Its current expected exceptions
(Black-Scholes grad and Coral Parquet) are isolated under `tests_blocked/`:

```sh
chelis test tests/ --jobs auto
chelis test tests/ --jobs 1   # serial fallback for debugging
```

## 4. Lint Inventory

```sh
chelis lint .                              # non-blocking nomenclature inventory
chelis lint --check .                      # blocking lint gate
```

The strict gate passes under Chelis 0.16.1 with zero error-severity
findings. One existing `prefer-pipe-operator` advisory remains in
`src/capstone/transformerblock.ch`; advisory diagnostics do not fail
`lint --check`. Treat new or edited examples as style-clean.

## 5. C backend (full lowering)

The C-backend harness is an independent production-lane oracle even for
features that also execute in the `0.16.1` evaluator:

```sh
python3 -m pytest -q tests/test_c_backend.py
```

This builds supported programs under `verify/`, links against
`libchelis_runtime.a` + OpenBLAS, runs the binary, and diffs stdout
against the committed golden in `verify/expected/<name>.txt`.

To do it by hand for one program:

```sh
cp verify/grad_quadratic.ch /tmp/grad_quadratic.ch
chelis build /tmp/grad_quadratic.ch --output /tmp/grad_quadratic
cd /tmp/grad_quadratic
gcc -O2 -fopenmp grad_quadratic.c -L. -lchelis_runtime \
    -lopenblas -lm -lpthread -ldl -o grad_quadratic
./grad_quadratic
# dsumsq = tensor(shape=[3], data=[2.0, 4.0, 6.0])
```

(Note: `chelis build`'s auto-link command misses `-lopenblas`. The
explicit `gcc` invocation works around that.)

## 6. Surf ↔ Deep regeneration

After editing any `.ch`:

```sh
python3 scripts/regen_deep.py            # walks src/, tests/, verify/
python3 scripts/regen_octant.py          # walks octant/
python3 scripts/sync_negative_tests.py   # materializes tests_neg/learner/
```

CI fails on drift. Run these before committing.

## 7. Python harness (orchestration for the non-Chelis lanes)

```sh
python3 -m pytest tests/
```

Covers structured learner-negative diagnostics, Octant pipeline round-trips,
c-earchin proof diagnostics, C-backend lowering goldens, workflow-pin fixtures,
and Surf-Deep drift. Native negative and blocked contracts additionally run via
`chelis test tests_neg/ --expect neg` and `chelis test tests_blocked/ --expect blocked`. See
[`tests/README.md`](../tests/README.md) for the breakdown.

## What to read next

- [`curriculum.md`](curriculum.md) — guided reading path through the
  corpus
- [`architecture.md`](architecture.md) — how the directories map to
  the compiler pipeline
- [`feature_matrix.md`](feature_matrix.md) — every primer-claimed
  feature → the file that exercises it
- [`surf_and_deep.md`](surf_and_deep.md) — why every program ships
  in both forms
- [`discrepancies.md`](discrepancies.md) — verbatim compiler error
  messages for every IR-evaluator-vs-C-backend gap
- Per-area catalogs: [`../src/basics/README.md`](../src/basics/README.md),
  [`../src/std/README.md`](../src/std/README.md),
  [`../src/coral/README.md`](../src/coral/README.md),
  [`../src/nautilus/README.md`](../src/nautilus/README.md),
  [`../src/capstone/README.md`](../src/capstone/README.md),
  [`../verify/README.md`](../verify/README.md),
  [`../octant/README.md`](../octant/README.md),
  [`../tests/README.md`](../tests/README.md)

## Layout (recap)

```text
hello-chelis/
├── README.md                top-level overview
├── reef.toml                compiler + shell pins
├── src/                     Hello.* modules                — chelis check
├── tests/                   chelis-native + python tests   — chelis test, pytest
├── verify/                  C-backend lowering programs    — pytest test_c_backend.py
├── octant/                  LaTeX + Deep + Surf triples    — pytest test_octant_pairs.py
├── docs/                    this file + the rest
├── scripts/                 regen_deep.py, regen_octant.py
├── docker/                  Dockerfile + docker-compose.yml
└── .github/workflows/       CI: lint inventory + check + test + C-backend + drift
```
