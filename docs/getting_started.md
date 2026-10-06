# Getting started

This page covers installing and running the corpus. For a guided reading
order, see [`curriculum.md`](curriculum.md).

## 1. Build the image

Install [GitHub CLI](https://github.com/cli/cli#installation) before building.
Sign in with any GitHub account:

```sh
git clone https://github.com/Chelis-Lang/hello-chelis.git
cd hello-chelis
gh auth login --web
gh auth status
export GITHUB_TOKEN=$(gh auth token)
docker compose -f docker/docker-compose.yml build
```

The image is `ubuntu:24.04` plus:

- the `chelis` CLI, `libchelis_runtime.a`, and its headers, from the chelis
  release tarball;
- the `coral` and `nautilus` packages, installed into the local Reef registry with
  `chelis reef install --from-github` (`chelis-std` ships with the compiler);
- GCC, OpenBLAS, and libgomp for the C backend, and valgrind;
- `uv` with a uv-managed Python environment for the test harness.

The toolchain and imported packages come from public release assets. The
c-earchin proof witnesses are committed in this repository, and the image
compiles a C smoke test. `GITHUB_TOKEN` is passed as a BuildKit secret and
used only to authenticate release downloads, which
`chelis reef install --from-github` requires even for public releases.

The image is `linux/amd64` because Chelis publishes Linux binaries for x86_64
only. `docker-compose.yml` pins that platform, so on Apple Silicon Docker
builds and runs the image under emulation.

You can also work without Docker: install the toolchain with `chelisup`
(see the Chelis
[install guide](https://github.com/Chelis-Lang/chelis/blob/main/docs/book/src/install.md)),
which reads the pinned version from `reef.toml`.

## 2. Open a shell in the container

```sh
docker compose -f docker/docker-compose.yml run --rm hello-chelis
```

Your checkout is mounted at `/workspace`, and everything below runs from there.

## 3. Type-check: `chelis check`

```sh
chelis check src/basics/hellotensor.ch
```

`chelis check` parses the file and runs type, dimension, effect, and
linearity checking. Pointed at any file inside the package, it checks the
whole package, so one invocation covers every module. It prints a JSON report;
`"errors": []` means the package is clean.

## 4. Run the tests: `chelis test`

```sh
chelis test tests/ --jobs auto
chelis test tests/basics/gradbasic.ch            # a single file
chelis test tests_neg --expect neg               # programs that must be rejected
chelis test tests_blocked --expect blocked       # known upstream gaps
```

Each `tests/<area>/<name>.ch` exercises the matching `src/<area>/<name>.ch`.

## 5. Lint

```sh
chelis lint --check .
```

This is the CI lint gate. It fails on error-severity findings; advisory
findings are printed but do not fail it.

## 6. Compile to C

```sh
uv run --group test pytest -q tests/test_c_backend.py
```

This compiles every program in `verify/` with `chelis build`, links it
against `libchelis_runtime.a` and OpenBLAS, runs it, and compares its output
with `verify/expected/<name>.txt`.

To do one by hand:

```sh
cp verify/grad_quadratic.ch /tmp/grad_quadratic.ch
chelis build /tmp/grad_quadratic.ch --output /tmp/grad_quadratic
cd /tmp/grad_quadratic
gcc -O2 -fopenmp grad_quadratic.c -L. -lchelis_runtime \
    -lopenblas -lm -lpthread -ldl -o grad_quadratic
./grad_quadratic
# dsumsq = tensor(shape=[3], data=[2.0, 4.0, 6.0])
```

`chelis build` writes C sources and a copy of the runtime library, and prints
a suggested `gcc` command; it does not invoke the C compiler itself. The
program is copied out of the repo first because `verify/` is not a source
root of the package; see [`../verify/README.md`](../verify/README.md).

## 7. Regenerate generated files

```sh
uv run scripts/regen_deep.py      # maintained Surf/Deep pairs
```

Run it after editing a `.ch` in the
[maintained paired corpus](surf_and_deep.md). CI fails if a paired `.dp`
differs from what `chelis deep` produces.

## 8. The Python harness

```sh
uv run --group test pytest tests/
```

This covers what `chelis test` does not: Deep drift, the structured error
kind of each rejected program, C-backend build-and-run, and c-earchin
proofs. See [`../tests/README.md`](../tests/README.md).

## What to read next

- [`curriculum.md`](curriculum.md): a reading path through the corpus
- [`architecture.md`](architecture.md): how the compiler pipeline maps onto
  the directories
- [`feature_matrix.md`](feature_matrix.md): each language feature and the
  file that exercises it
- [`surf_and_deep.md`](surf_and_deep.md): where Surf and Deep are paired and
  how the pair is checked
