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
- Python 3 + pytest (for the fallback test harness)
- Rust toolchain (we build chelis from source — the canonical-org
  GH release tarball is the production install path on real CI with
  a `GITHUB_TOKEN`; this image works in air-gapped environments
  without one)
- The `chelis` and `octant` CLIs from the v0.6.1 / v0.4.2 source tags
- `libchelis_runtime.a` installed at `/usr/local/lib/`
- The shells `chelis-std` 0.2.0, `coral` 0.6.1, `nautilus` 0.6.1,
  and `octant` 0.4.2 built and published into the local Reef
  registry

First build takes ~5 minutes; rebuilds reuse the layer cache.

## 2. Inside the container

```sh
docker compose -f docker/docker-compose.yml run --rm hello-chelis
```

Your repo checkout is mounted at `/workspace`. Everything below runs
from there.

## 3. The primary gate — `chelis test`

Chelis's native test runner discovers `def test_*() -> unit ! { Test }`
functions in `tests/` and runs the `Std.Test.assert_*` calls:

```sh
chelis test tests/                          # all 105 tests
chelis test tests/basics/                   # one folder
chelis test tests/basics/hellotensor.ch     # one file
chelis test --filter add_vec tests/         # name filter
```

## 4. Front-end + lint

```sh
chelis check src/basics/hellotensor.ch     # parse + types + dim
                                            # + effect + linearity
chelis lint --check .                      # nomenclature
```

`chelis check` validates the entire project on any single-file
invocation: all 200K+ typed nodes get re-loaded each call. There's
no per-file or directory mode.

## 5. C backend (full lowering)

The IR evaluator at v0.6.1 doesn't run every primitive; the C backend
does. To exercise `grad`, `realize`, tensor `relu`/`sigmoid`/`cast`
end-to-end:

```sh
python3 -m pytest -q tests/test_c_backend.py
```

This builds every program under `verify/`, links against
`libchelis_runtime.a` + OpenBLAS, runs the binary, and diffs stdout
against the committed golden in `verify/expected/<name>.txt`.

To do it by hand for one program:

```sh
cp verify/grad_works.ch /tmp/grad_works.ch
chelis build /tmp/grad_works.ch --output /tmp/grad_works
cd /tmp/grad_works
gcc -O2 -fopenmp grad_works.c -L. -lchelis_runtime \
    -lopenblas -lm -lpthread -ldl -o grad_works
./grad_works
# dw = tensor(shape=[3], data=[1.0, 2.0, 3.0])
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
Octant pipeline round-trips, C-backend lowering goldens, Surf-Deep
drift. See [`tests/README.md`](../tests/README.md) for the breakdown.

## What to read next

- [`curriculum.md`](curriculum.md) — guided reading path through the
  corpus
- [`architecture.md`](architecture.md) — how the directories map to
  the compiler pipeline
- [`feature-matrix.md`](feature-matrix.md) — every primer-claimed
  feature → the file that exercises it
- [`surf-and-deep.md`](surf-and-deep.md) — why every program ships
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
└── .github/workflows/       CI: chelis lint + check + test + C-backend + drift
```
