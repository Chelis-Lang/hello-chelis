# Getting started

Chelis is a young language. It is faster to get a working environment up
inside Docker than to build the compiler from source, and that is the path
this repo standardizes on.

## 1. Build the image

```sh
git clone https://github.com/Chelis-Lang/hello-chelis.git
cd hello-chelis
docker compose -f docker/docker-compose.yml build
```

The image is `ubuntu:24.04` plus:

- GCC, OpenBLAS, libgomp, valgrind (for the C backend)
- Python 3 (for the test harness)
- The `chelis` CLI from
  [release v0.6.1](https://github.com/Chelis-Lang/chelis/releases/tag/v0.6.1)
  (sha256 verified at build time)
- The shells `coral` v0.6.1, `nautilus` v0.6.1, and `octant` v0.4.2,
  installed via `chelis reef install`

The build takes a few minutes (most of it is the apt-get layer). Subsequent
builds reuse cached layers.

## 2. Drop into the container

```sh
docker compose -f docker/docker-compose.yml run --rm hello-chelis
```

Your repo checkout is mounted at `/workspace`. Everything you do inside the
container is visible on the host.

## 3. Run your first example

```sh
chelis check examples/01_language_basics/01_hello_tensor.ch
```

You should see a JSON fitness report. `score` should be `1.0` and `errors`
should be empty.

```sh
chelis eval examples/01_language_basics/01_hello_tensor.ch
```

Runs the IR evaluator (interactive mode). For production-style execution:

```sh
chelis build examples/01_language_basics/01_hello_tensor.ch --target c --out-dir build/hello
./build/hello/main
```

## 4. Sweep all examples

Chelis has its own test runner. Every example here defines one or more
`def test_*() -> unit ! { Test }` functions whose `Std.Test.assert_*`
calls are the actual specification of correct behavior:

```sh
chelis test examples/
```

That's the primary gate. Anything that fails here is a real bug in the
example or a regression in the compiler/shells.

Python is fallback orchestration only — it covers the cases where the
native runner doesn't apply (snippets that must be rejected, Octant
pair regeneration, audit-chain greps in emitted C). See
[`tests/README.md`](../tests/README.md) for the breakdown:

```sh
python3 -m pytest tests/
```

For a quick standalone check across the corpus:

```sh
chelis check examples/
```

## 5. Where to read next

- [`docs/architecture.md`](architecture.md) — how the directories map to the
  primer's architecture diagram and what each example demonstrates.
- [`docs/feature-matrix.md`](feature-matrix.md) — the full table of
  primer-claimed features and which example exercises each one.
- [`docs/shells/std.md`](shells/std.md), [`coral.md`](shells/coral.md),
  [`nautilus.md`](shells/nautilus.md), [`octant.md`](shells/octant.md) —
  one page per shell, with cross-links into the corpus.

## Caveats

- **Linux x86_64 + Docker is the only supported platform here.** The Chelis
  v0.6.1 release also ships a `darwin-arm64` tarball, but this repo's CI
  and tooling are pinned to the linux-x86_64 path. You can adapt the
  Dockerfile by switching the tarball URL, but the existing image will not
  run on Apple Silicon natively.
- **Some primer features are designed but not yet shipped.** The compiler's
  stable name surface is narrower than the primer suggests. Examples in
  this repo stick to what `chelis check` accepts on v0.6.1 — see
  [`docs/feature-matrix.md`](feature-matrix.md) for the deltas.
- **Reef's GitHub-Releases install path is recent.** If `chelis reef install
  --from-github` fails on your image build, `scripts/install_shells.py`
  falls back to cloning each shell repo and running `chelis reef pack` +
  `chelis reef install --from-archive`.
