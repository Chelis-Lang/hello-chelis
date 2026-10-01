# hello-chelis, a Chelis shell

## Repo Identity

hello-chelis is the **executable teaching corpus** for Chelis. Someone who has
never seen the language should be able to clone this repo, run the supported
lessons, and read their way from a first tensor to a returns-and-risk pipeline.
Every example is a real program
intended for checking, testing, and (where the C backend supports it) lowering
and running. Nothing here is illustrative pseudo-code.

That makes this repo the ecosystem's **integration canary**: it is the only shell
that consumes `chelis-std`, `coral`, `nautilus`, `octant`, and `c-earchin`
together, so it is the first place a cascade that does not compose
shows up. It is also the **Docker shell** — its CI ships and tests inside an
image built from the published release tarball rather than a host toolchain.

The upstream language rules and specifications live in
[`Chelis-Lang/chelis`](https://github.com/Chelis-Lang/chelis). Paths to `spec/`
and `agent-skills/` in the inherited contract refer to that repository unless
the path exists here. The
[`shell repo contract`](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/shell_repo_contract.md)
also applies.

<!-- shell-local:exclude:begin -->
<!-- ## Review And Merge -->
<!-- ## Spec Authority And Design Discipline -->
<!-- ## Change Hygiene -->
<!-- ## Issue Tracking -->
<!-- ## Environment And Tooling -->
<!-- ## Subagents -->
<!-- ## The Chelis-Lang Repositories -->
<!-- ## Pointers -->
<!-- shell-local:exclude:end -->

<!-- BEGIN CHELIS MANAGED BLOCK: agents-inheritance chelis@0.18.12 (sha256:024191edd26f0388) -->
# Chelis Agent Contract

Keep this file concise and relevant to every agent working in this repository.
Each added token is read tens of thousands of times. State a rule once, link the
document that owns the detail, and put the explanation in that document, not here.

`CLAUDE.md` is a symlink to this file so Claude-style and Codex-style entry points do
not drift.

## What Chelis Is

Chelis is a functional language for AI research, built for a workflow where a coding
agent is the primary author and a human is the supervisor, and where the programs are
themselves AI systems: models, training loops, search spaces, learned functions. The
bet is that a type system, representation, and compilation model designed around AI
primitives from the start beat ones bolted onto Python or a systems language later. It
is not a general-purpose language, a systems language, a web framework, or a Python
replacement. `spec/00-context.md` and `spec/design/chelis_canonical_reference.md` own
the full statement; their specifics may lag, their intent does not. When a tradeoff
appears, apply these in order:

1. **Unambiguity over ergonomics.** The author is an agent. The friction a human feels
   spelling out every type, effect, dtype, and dimension is not worth a reading the
   compiler has to guess at.
2. **Composition over special cases.** A new capability composes existing primitives
   before it earns a new one.
3. **Inference over annotation.** Where the checker determines something uniquely, the
   author does not repeat it; intermediates carry no ascription.
4. **Machine generation first.** A convenience that exists only for a human typist is
   not a reason to add syntax, a default, or a fallback.
5. **Additive sugar only.** Every surface form desugars to the core; nothing in the
   surface has semantics the core lacks.
6. **Explicit over implicit.** No implicit broadcasting (`expand` only), no implicit
   precision promotion, no implicit currying or partial application, no silent
   narrowing at ingress, no hidden effects. Where intent cannot be determined uniquely,
   the compiler rejects.
7. **Small language, big library.** The compiler knows only the closed RISC primitive
   set and its derived built-ins; everything else is a library. The canonical reference
   §8.5 has the core/standard-library/external-library taxonomy.
8. **Future-proof without over-building.** Decide the rule fully now, implement what
   the phase needs, and never narrow a rule to what a lane implements today.

Two corollaries govern how the compiler itself is changed. Chelis is pre-compatibility
unless a controlling contract says otherwise, so prefer the structural design that
makes a defect class impossible over a smaller-blast-radius patch, a legacy default, a
versionless compatibility fallback, or phase deferral; close the class, not the
instance. And determinism is part of the contract: for fixed program text, compiler
build, target, and declared inputs, every check, evaluation, and build result is a
function of those inputs, and feedback that varies between identical runs is a defect.

## Quality Standards

### Spec-First Development

- Before writing implementation, write test stubs derived from the owning spec.
- Every spec requirement should have a corresponding test before the code exists.
- If the spec says "X is a type error," write the failing test before implementing
  the checker.

### Negative Test Parity

- For every test that checks something works, add the corresponding failure test.
- If you cannot name the failure case, the spec understanding is still weak.

### Do Not Trust Green

- Passing tests prove alignment with the tests, not necessarily with the spec.
- After green CI, check what active requirements still lack tests.
- Audit silent fallbacks, default values, empty error vectors, and `unwrap_or` paths.

## Writing Chelis Source

Load the [`example-corpus` skill](agent-skills/example-corpus/SKILL.md) before writing
any `.ch`; it carries the Surf style rules, the parse-breaking spellings, and the Deep
AST contract. `spec/02-surf-syntax.md` §0.1 is the authority.

- `chelis build`, `check`, `validate`, and `eval --file` run `chelis fmt --check` and the
  blocking `chelis lint` rules before the front end; style failures block the build.
  `--allow-style-violations` is for emergency local builds only, never CI, and
  `CHELIS_STYLE_GATE_DISABLE=1` is reserved for the integration-test corpus. Run
  `chelis fmt --inplace <file>` and `chelis lint --check` before pushing.
- Type system: no implicit precision promotion, named tensor dimensions match by name,
  no implicit broadcasting (explicit `expand` only), integer literals default to `i32`
  and float literals to `f32`.
- `chelis build` emits C, a header, runtime artifacts, and compile flags; `--target hip`
  emits host code with embedded kernel strings. Neither invokes the native compiler.

<!-- END CHELIS MANAGED BLOCK: agents-inheritance -->

## Toolchain Policy

Install the pinned toolchain via `chelisup`; never hand-symlink a machine-global
default. Python is uv-managed (`uv run`, dependency groups in `pyproject.toml`,
`uv.lock` committed). See the managed block above for the upstream contract.

CI runs inside the image built from [`docker/Dockerfile`](docker/Dockerfile),
which installs the toolchain, the Octant CLI, and the shell packages from their
release assets. That image carries its own copy of the pins, which
`conform bump` does not rewrite. When the pin moves, update together:
`ARG CHELIS_VERSION` and the shell `ARG`s in the Dockerfile, the `build-args:`
block in [`ci.yml`](.github/workflows/ci.yml), and the `image:` tag in
[`docker-compose.yml`](docker/docker-compose.yml). (`conform bump` handles
`reef.toml` and `env.CHELIS_VERSION` in [`release.yml`](.github/workflows/release.yml).)
CI does not install through `chelisup`; the current `conform audit` reports
row 5 (`toolchain-installer`) as PASS for this documented image path.
hello-chelis#26 tracks resolving the image's pins from `reef.toml`.

## Pin Bump Checklist

A pin bump is a de-narrowing event. Bump only through a `chelis reef conform bump`
PR that runs the blocked-probe suite, the staleness/narrowing audit, and restamps
`docs/CHELIS_SURFACE.md`. Never edit the pin directly on `main`.

This repo is the **leaf** of the cascade: it pins released `coral` and `nautilus`
packages, and reef rejects a dependency whose `package.compiler`
does not equal the running compiler. A chelis bump therefore cannot land here
until every one of those shells has published a release pinned to the same
version. Bump this repo last.

**`reef.lock` records artifact hashes, so it can only be regenerated against
real published releases.** Validating a bump early against sibling shells that
have staged but not tagged their releases means building their packages into a
private Reef registry (`CHELIS_REEF_HOME`) — and every `chelis reef build` in
that setup rewrites `reef.lock` with *your local build's* hashes, which are not
the release's. Those must never be committed: they assert integrity for bytes
nobody else will ever produce, and the giveaway is a `local_registry` dependency
with no `remote_origin` line. Check `git diff reef.lock` before every commit in a
cascade bump, and regenerate the lock for real only after the siblings tag.

Two lanes of generated artifacts must be regenerated in the same change set:

- `uv run scripts/regen_deep.py` after any `.ch` edit (the committed `.dp`
  sidecars are byte-compared in CI).
- `uv run scripts/regen_octant.py` when the octant pin moves or the Surf
  printer changes; the `.ch` third of each octant triple is `chelis surf`
  output and moves with the compiler even when the `.tex` and `.dp` do not.

## Scaffolding Drift Rule

All shells share one scaffolding shape. Mirror any structural change into the
sibling shells in the same change set, or record a per-repo divergence. Contract
changes land upstream first (`Chelis-Lang/chelis`) and propagate here via
`chelis reef conform sync`.

### Recorded divergences

- **`tests_neg/` carries two oracles, not one.** The contract's
  `chelis test tests_neg --expect neg` pins each case's diagnostic *substring*;
  `tests/test_negative_examples.py` additionally asserts the structured error
  *kind* from the `-- chelis-expect-fail: <ErrorKind>` header, which the native
  runner cannot see. Both read the same corpus, so they cannot drift apart.
- **`docs/CHELIS_SURFACE.md` is domain-scoped to the teaching corpus** rather
  than to one library's primitive families, because this shell has no single
  domain. See that file's preamble.
