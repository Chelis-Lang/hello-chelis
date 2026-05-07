# hello-chelis

A walking tour of the [Chelis](https://github.com/Chelis-Lang/chelis) language
and its shipped shells, built as a corpus of small, runnable example programs.

This repository is the canonical "first stop" for evaluating Chelis on a real
machine: install the toolchain, install the shells, work through the examples
folder by folder, run the tests, read the docs.

## What's covered

| Area | Folder | What you'll see |
|---|---|---|
| Language basics | [`examples/01_language_basics/`](examples/01_language_basics/) | named dimensions, no broadcasting, no implicit precision promotion, ADTs + match, modules, effects (`Random`, `IO`), linearity (`copy`/`&borrow`), `grad`, `vmap`, `jit`, `realize`, macros |
| `chelis-std` | [`examples/02_std/`](examples/02_std/) | activations, normalizations, reductions, losses, `Decimal[P, S]`, `DateTime`, `List` / `Dict`, fold/scan, tensor I/O |
| `coral` (dataframes) | [`examples/03_coral/`](examples/03_coral/) | typed columns, `group_by`, joins, rolling windows, reshape, CSV/JSON, **AD through a dataframe** |
| `nautilus` (numerics) | [`examples/04_nautilus/`](examples/04_nautilus/) | special functions, distributions, linear algebra, statistics, distance metrics, root-finding, integration, ODE/SDE, interpolation, optimization, hypothesis testing, curve fit |
| `octant` (LaTeX bridge) | [`examples/05_octant/`](examples/05_octant/) | translate `.tex` formulas to typed Chelis Deep |
| Capstones | [`examples/06_capstone/`](examples/06_capstone/) | Black-Scholes Greeks via Octant + Nautilus + `grad`; linear regression via Coral + Std; transformer block via Std; an end-to-end ML pipeline across all four shells |

## Quickstart

The compiler and shells run inside Docker. You don't need a Rust toolchain.

```sh
# Build the image (Ubuntu 24.04 + GCC + OpenBLAS + chelis v0.6.1 + shells)
docker compose -f docker/docker-compose.yml build

# Drop into a shell with everything ready
docker compose -f docker/docker-compose.yml run --rm hello-chelis

# Inside the container:
chelis check examples/01_language_basics/01_hello_tensor.ch
chelis eval  examples/01_language_basics/01_hello_tensor.ch
chelis build examples/01_language_basics/01_hello_tensor.ch --target c
```

To run the full test sweep:

```sh
# Primary gate — Chelis's native test runner picks up every
# `def test_*() -> unit ! { Test }` and runs the assertions.
docker compose -f docker/docker-compose.yml run --rm hello-chelis \
    chelis test examples/

# Fallback orchestration (negative examples, Octant pair regeneration,
# C-backend audit-chain greps) — see tests/README.md.
docker compose -f docker/docker-compose.yml run --rm hello-chelis \
    python3 -m pytest tests/
```

See [`docs/getting-started.md`](docs/getting-started.md) for the long form.

## Compiler version

Pinned to **chelis `0.6.1`** with **`chelis-std` 0.2.0**, **coral 0.6.1**,
**nautilus 0.6.1**, and **octant 0.4.2**. The `compiler = "=0.6.1"` pin in
`reef.toml` is hard — the language is pre-1.0 and breaking changes ship between
minor versions, so trying to run these examples against a different compiler
is unlikely to work without edits.

## Repo layout

```text
hello-chelis/
├── docs/                            extended documentation
│   ├── getting-started.md
│   ├── architecture.md
│   ├── feature-matrix.md
│   └── shells/{std,coral,nautilus,octant}.md
├── examples/                        executable + readable corpus
│   ├── 01_language_basics/          pure language features
│   ├── 02_std/                      Std.* surfaces
│   ├── 03_coral/                    Coral.* dataframes
│   ├── 04_nautilus/                 Nautilus.* numerics
│   ├── 05_octant/                   octant translate <file>.tex
│   └── 06_capstone/                 multi-shell integrations
├── tests/                           Python harness over chelis check/eval/build
│   └── expected/                    golden outputs
├── scripts/                         install + run + lint helpers (Python only)
├── docker/                          Dockerfile + docker-compose.yml
├── .github/workflows/               CI (chelis check, lint, run examples)
├── reef.toml                        compiler + shell pins
└── README.md                        you are here
```

## License

MIT. See [`LICENSE`](LICENSE).

## Pointers

- [Chelis primer (canonical reference)](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/chelis_canonical_reference.md)
- [Surf syntax spec](https://github.com/Chelis-Lang/chelis/blob/main/spec/02-surf-syntax.md)
- [`chelis-std` SKILL](https://github.com/Chelis-Lang/chelis/blob/main/packages/chelis-std/SKILL.md)
- [Coral SKILL](https://github.com/Chelis-Lang/coral/blob/main/SKILL.md)
- [Nautilus SKILL](https://github.com/Chelis-Lang/nautilus/blob/main/SKILL.md)
- [Octant SKILL](https://github.com/Chelis-Lang/octant/blob/main/SKILL.md)
