# hello-chelis, a Chelis shell

## Repo Identity

hello-chelis is the **executable teaching corpus** for Chelis. Someone who has
never seen the language should be able to clone this repo, run the supported
lessons, and read their way from a first tensor to a returns-and-risk pipeline.
Every example is a real program
intended for checking, testing, and (where the C backend supports it) lowering
and running. Nothing here is illustrative pseudo-code.

That makes this repo the ecosystem's **integration canary**: it is the only shell
that consumes `chelis-std`, `coral`, and `nautilus` together while exercising
committed `c-earchin` witnesses. It is also the
**Docker shell** — its CI ships and tests inside an
image built from the published release tarball rather than a host toolchain.

The upstream language rules and specifications live in
[`Chelis-Lang/chelis`](https://github.com/Chelis-Lang/chelis). Paths to `spec/`
and `agent-skills/` in the inherited contract refer to that repository unless
the path exists here. The
[`shell repo contract`](https://github.com/Chelis-Lang/chelis/blob/main/spec/design/shell_repo_contract.md)
also applies.

For PR review, use the synced `agent-skills/redteam-exec/SKILL.md` and its
hello-specific worktree handoff. For a completion claim, use
`agent-skills/phase-gate/SKILL.md` and the Docker corpus gate it names.

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

<!-- BEGIN CHELIS MANAGED BLOCK: agents-inheritance chelis@0.19.0 (sha256:63dc71e671d4158b) -->
# Chelis Agent Contract

Keep this file concise and relevant to every agent working in this repository.
Each added token is read tens of thousands of times. State a rule once, link the
document that owns the detail, and put the explanation in that document, not here.

`CLAUDE.md` is a symlink to this file so Claude-style and Codex-style entry points do
not drift.

## What Chelis Is

Chelis is a numerical computing language for code that agents write and people
supervise. Tensors carry named dimensions and precision in their type; the compiler
checks shapes, precision, effects, and ownership before anything runs, and `chelis
prove` checks the properties an author states, naming the method behind each result.
The bet is that numerical code an agent can reason about, and a person can review
through its types and properties, beats code whose mistakes first surface at run time.
Chelis is general purpose within numerical computing; the worked examples come from
quantitative finance. Differentiation and machine-learning programs are research
directions, not the definition of the language. It is not a systems language, a web
framework, a deep-learning framework, or a general scripting replacement for Python.
`spec/00-context.md` and `spec/design/chelis_canonical_reference.md` own the full
statement; their specifics may lag, their intent does not. When a tradeoff
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
- `chelis build` invokes the native compiler for C, HIP, or Metal and produces an
  executable or static library, retaining sources and runtime artifacts. `--emit-c`
  stops after source emission. CPU is the acceptance priority; GPU targets remain
  prerelease. See `docs/book/src/backends.md`.

<!-- END CHELIS MANAGED BLOCK: agents-inheritance -->

## Toolchain Policy

Install the pinned toolchain via `chelisup`; never hand-symlink a machine-global
default. Python is uv-managed (`uv run`, dependency groups in `pyproject.toml`,
`uv.lock` committed). See the managed block above for the upstream contract.

CI runs inside the image built from [`docker/Dockerfile`](docker/Dockerfile),
which installs the toolchain and imported packages from their
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

Regenerate the generated artifacts in the same change set:
`uv run scripts/regen_deep.py` after any `.ch` edit (the committed `.dp`
sidecars are byte-compared in CI).

## Scaffolding Drift Rule

All shells share one scaffolding shape. Mirror any structural change into the
sibling shells in the same change set, or record a per-repo divergence. Contract
changes land upstream first (`Chelis-Lang/chelis`) and propagate here via
`chelis reef conform sync`.

### Recorded divergences

- **Agent-skill gate commands are shell-local.** The red-team skill keeps
  Chelis's review protocol but uses git and process evidence in place of the
  compiler-only `scripts/worktree_status.py`; the phase skill points to this
  shell's Docker corpus gate in place of `scripts/gate.py`.
- **`tests_neg/` carries two oracles, not one.** The contract's
  `chelis test tests_neg --expect neg` pins each case's diagnostic *substring*;
  `tests/test_negative_examples.py` additionally asserts the structured error
  *kind* from the `-- chelis-expect-fail: <ErrorKind>` header, which the native
  runner cannot see. Both read the same corpus, so they cannot drift apart.
- **`docs/CHELIS_SURFACE.md` is domain-scoped to the teaching corpus** rather
  than to one library's primitive families, because this shell has no single
  domain. See that file's preamble.
