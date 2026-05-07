# Getting started

## 1. Build the image

```sh
git clone https://github.com/Chelis-Lang/hello-chelis.git
cd hello-chelis
docker compose -f docker/docker-compose.yml build
```

The image is `ubuntu:24.04` plus:

- GCC, OpenBLAS, libgomp, valgrind (for the C backend)
- Python 3 + pytest (for the fallback test harness)
- Rust toolchain (we build chelis from source — the canonical-org GH
  release tarball is the production install path with a `GITHUB_TOKEN`
  in real CI; this image works in air-gapped environments without one)
- The `chelis` and `octant` CLIs from the v0.6.1 / v0.4.2 source tags
- The shells `chelis-std` 0.2.0, `coral` 0.6.1, `nautilus` 0.6.1, and
  `octant` 0.4.2 published into the local Reef registry

## 2. Inside the container

```sh
docker compose -f docker/docker-compose.yml run --rm hello-chelis
```

Your repo checkout is mounted at `/workspace`.

## 3. The primary gate: `chelis test`

Chelis's native test runner discovers `def test_*() -> unit ! { Test }`
functions in `tests/` and runs the `Std.Test.assert_*` assertions:

```sh
chelis test tests/                          # everything
chelis test tests/basics/                   # one folder
chelis test tests/basics/hellotensor.ch     # one file
chelis test --filter add_vec tests/         # name filter
```

## 4. Front-end + lint

```sh
chelis check src/basics/hellotensor.ch     # one file (validates the
                                           # whole project transitively)
chelis lint --check .                      # nomenclature gate
```

`chelis check` validates the entire project on any single-file invocation:
all 200K+ typed nodes get re-loaded each call. There's no per-file mode.

## 5. C backend

```sh
chelis build --target c src/basics/hellotensor.ch -o /tmp/hello
/tmp/hello
```

The emitted C carries `// span:` markers tying every line back to a Surf
location — see `tests/test_chelis_build.py` for the audit-chain
invariant check.

## 6. Python harness (fallback only)

```sh
pip install pytest
python3 -m pytest tests/
```

Covers the lanes `chelis test` doesn't — see [`tests/README.md`](../tests/README.md).

## Caveats baked into v0.6.1

- The IR evaluator (`chelis test`) doesn't yet implement runtime
  lowering for: `relu`/`sigmoid`/`gelu`/`silu`/`max_elem`,
  tensor-form `exp`/`log`, `cast` on tensors, `jit`. They DO
  `chelis check` cleanly and DO compile via `chelis build --target c`.
- `bf16` is not yet a supported cast target. f32, f64, int8/32/64,
  bool work.
- The chelis-lang shells are private during pre-launch — `chelis reef
  install --from-github` requires `GITHUB_TOKEN`. The Docker image
  side-steps this by cloning shell sources at the pinned tags.

## Layout (recap)

```text
hello-chelis/
├── reef.toml                 compiler + shell pins
├── src/                      Hello.* modules — chelis check only here
├── tests/                    chelis test discovers here
├── octant/                   .tex + verified .ch/.dp from octant translate
├── docker/                   Dockerfile + docker-compose.yml
├── docs/                     this file + architecture + feature-matrix
└── .github/workflows/        CI
```
