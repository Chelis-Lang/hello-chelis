# Getting started

If you want a guided reading path through the corpus once it's
running, see [`curriculum.md`](curriculum.md). This page is just
install + first commands.

## 1. Build the image

```sh
git clone https://github.com/Chelis-Lang/hello-chelis.git
cd hello-chelis
docker compose -f docker/docker-compose.yml build
```

The image is `ubuntu:24.04` plus:

- GCC, OpenBLAS, libgomp, valgrind (for the C backend)
- Python 3 + pip (CI installs pytest before running the fallback harness)
- The `chelis` and `octant` CLIs from prebuilt release tarballs
- `libchelis_runtime.a` installed at `/usr/local/lib/`
- The shells `chelis-std` 0.3.0, `coral` 0.7.6, `nautilus` 0.7.6,
  `octant` 0.4.5, and `c-earchin` 0.2.2 installed into the local Reef
  registry from GitHub release assets

First build requires `GITHUB_TOKEN` access to the private Chelis-Lang
repos and downloads release artifacts instead of compiling toolchains
from source. Rebuilds reuse the layer cache.

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

`chelis check` validates the entire project on any single-file
invocation: all 200K+ typed nodes get re-loaded each call. There's
no per-file or directory mode.

The native IR evaluator still has documented primitive gaps, but the
full native test tree is a blocking lane:

```sh
chelis test tests/ --jobs auto
chelis test tests/ --jobs 1   # serial fallback for debugging
```

## 4. Lint Inventory

```sh
chelis lint .                              # non-blocking nomenclature inventory
```

The strict `chelis lint --check .` gate is not enabled for this
historical corpus yet because existing committed examples still carry
style diagnostics. Treat new or edited examples as style-clean.

## 5. C backend (full lowering)

The IR evaluator at v0.7.6 doesn't run every primitive. The C-backend
harness exercises supported native lowerings end-to-end and locks known
v0.7.6 symbolic-dimension codegen panics as expected failures:

```sh
python3 -m pytest -q tests/test_c_backend.py
```

This builds supported programs under `verify/`, links against
`libchelis_runtime.a` + OpenBLAS, runs the binary, diffs stdout against
the committed golden in `verify/expected/<name>.txt`, and separately
asserts the known compiler panics still fail with the expected reason.

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
```

CI fails on drift. Run these before committing.

## 7. Python harness (orchestration for the non-Chelis lanes)

```sh
python3 -m pytest tests/
```

Covers what `chelis test` doesn't: programs that must be rejected,
Octant pipeline round-trips, c-earchin proof diagnostics, C-backend
lowering goldens, and Surf-Deep drift. See
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
