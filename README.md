# hello-chelis

A runnable tour of the [Chelis](https://github.com/Chelis-Lang/chelis)
language and the packages built on it: `chelis-std`, `coral`, `nautilus`,
`shoals`, and `c-earchin`. Every module under `src/` is a real program that
type-checks, and nearly every one has a test under `tests/` that calls it
and asserts the result.
Standalone programs under `verify/` compile to C and run.

## Learn Chelis

The book, [Hello Chelis](https://chelis.ch/docs/hello-chelis/), starts with
a program that adds two vectors and works through shapes, borrowing,
precision, and derivatives in five small standalone files, each with the
output the compiler prints. Its source is in [`docs/book/`](docs/book/).
It then shows how to read the larger calculations in this repository.

## What's covered

| Area | Folder | Demonstrates |
|---|---|---|
| Language fundamentals | [`src/basics/`](src/basics/) | named dimensions, ADTs and `match`, modules, dimension polymorphism, precision and `cast`, explicit random keys and replay, borrowed tensor reads and explicit copy into an owned parameter, `grad`, `vmap`, `realize`, macros |
| `chelis-std` | [`src/std/`](src/std/) | elementwise math, normalization, reductions, exact `Decimal` arithmetic, `Date` arithmetic, `List` / `Dict` / iteration, text I/O |
| `coral` (typed dataframes) | [`src/coral/`](src/coral/) | typed columns, `group_by`, joins, rolling windows, reshape, CSV/JSON I/O |
| `nautilus` (numerics) | [`src/nautilus/`](src/nautilus/) | special functions, distributions, linear algebra, statistics, information theory, root-finding, integration, ODE/SDE, interpolation, optimization, hypothesis tests, curve fitting |
| `c-earchin` (requirements to proofs) | [`c-earchin/`](c-earchin/) | EARS requirements translated to property witnesses, proven by `chelis prove`, with failures reported against the requirement's source line |
| Capstones | [`src/capstone/`](src/capstone/) | Black-Scholes price and Greeks via `grad`, linear regression with an SGD step, returns and risk across `coral` and `nautilus`, and three `shoals` capstones: a yield curve, an American put priced three ways, and a VaR backtest |

## Run the examples

Install the compiler version that [`reef.toml`](reef.toml) names (see
[Install](https://chelis.ch/docs/chelis/install/)), then fetch the pinned
packages and run the tests:

```sh
git clone https://github.com/Chelis-Lang/hello-chelis.git
cd hello-chelis
chelis reef install --from-lockfile
chelis check src/basics/hellotensor.ch
chelis test tests/ --jobs auto
```

Or use Docker, which installs the pinned toolchain and packages from public
release assets with no GitHub account or token:

```sh
docker compose -f docker/docker-compose.yml build
docker compose -f docker/docker-compose.yml run --rm hello-chelis
```

The image is `linux/amd64`, the only Linux platform Chelis publishes binaries
for, so on Apple Silicon Docker runs it under emulation. Inside the
container your checkout is mounted at `/workspace`, where the `chelis check`
and `chelis test` commands above work as written.

## License

MIT. See [`LICENSE`](LICENSE).
