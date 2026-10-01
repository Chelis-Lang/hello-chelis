# hello-chelis, a Chelis shell

## Repo Identity

hello-chelis is the **executable teaching corpus** for Chelis. Someone who has
never seen the language should be able to clone this repo, run everything in it,
and read their way from a first tensor to a returns-and-risk pipeline once the
compiler-matching shell packages publish. Every example is a real program
intended for checking, testing, and (where the C backend supports it) lowering
and running. Nothing here is illustrative pseudo-code.

That makes this repo the ecosystem's **integration canary**: it is the only shell
that consumes `chelis-std`, `coral`, `nautilus`, `octant`, and `c-earchin`
together, so it is the first place a cascade that does not compose
shows up. It is also the **Docker shell** — its CI ships and tests inside an
image built from the published release tarball rather than a host toolchain.

<!-- shell-local:exclude:begin -->
<!-- ### Pull Request Lifecycle -->
<!-- ### Numeric Surface Discipline -->
<!-- ### OpenSpec -->
<!-- ### Python And Scripts -->
<!-- ### Build And Gate Commands -->
<!-- ## The Chelis-Lang Repositories -->
<!-- ## Pointers -->
<!-- shell-local:exclude:end -->

<!-- BEGIN CHELIS MANAGED BLOCK: agents-inheritance chelis@0.18.12 (sha256:8758a35ed63fd0bf) -->
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

## Review And Merge

### Red Team Rounds

Run every round through the [`redteam-exec` skill](agent-skills/redteam-exec/SKILL.md).
It carries the brief shape, the worktree-reuse rules, and the verify mode.

- Red team against the spec, the code, the tests, the examples, and the CLI behavior.
  Execute tests and commands; source inspection is not proof.
- Every pull request, documentation-only work included, gets at least one round before
  merge. A round is the whole live back-and-forth between one reviewer and the author,
  not a single review pass:
  1. A fresh local subagent reviews the exact head from an inline brief and reports
     its findings.
  2. The reviewer stays alive. The author repairs the findings in the worktree.
  3. The author hands the repair back, and the same reviewer verifies it and looks for
     similar issues the repair may have missed or introduced.
  4. Any further finding goes back to the author, and steps 2 and 3 repeat.
  5. The round ends only when that reviewer states it is satisfied.
  A reviewer that has reported is not finished; it is waiting for the fix. Ending the
  loop after the first report, or verifying a repair with a different reviewer, is not
  a round.
- A pull request gets at most three fresh rounds; a fourth needs the user's explicit
  approval. A prose-only pull request gets one, and a second needs the same approval.
  The pull request's round record is the counter. Verification by the standing reviewer
  does not count; the end-of-pull-request round does.
- A finding is in scope only when the pull request introduces it, worsens it, or claims
  to correct it. Discovery during review does not bring a pre-existing defect into scope.
- A confirmed in-scope P0 or P1 merits a fresh round after the current round finishes,
  within the cap. Unmigrated assertions, old comments, and minor documentation drift do
  not. A rebase does not by itself merit a round: send a hand-resolved intersection that
  stays within files the standing reviewer already read to that reviewer for focused
  verification, and use a fresh round only when the rebase introduces a new mechanism or
  touches files that reviewer did not read. A targeted review of substantial rebase
  overlap needs no permission and never counts toward the cap.
- For documentation and design reviews, severity follows contract impact. A wrong
  normative rule, or a plan that cannot close a named in-scope deliverable, is P0 or P1.
  A design document that misdescribes current `main`, or exposes a sequencing seam while
  the contract stays achievable, is P2 or P3 and is recorded as residual work, never
  promoted to a merge blocker. Wording, line-level accuracy of the pull request body,
  staleness against a sibling pull request's moving head, and anything whose fix would
  add text without a necessity sentence are out of scope.
- State a pull request's claim at the granularity its oracle proves. An unbounded
  universal claim invites sampling in every round and can never be closed.
- A finding class is the defect category, not its file, line, or wording instance.
  Every round record names the class of each finding. When two consecutive rounds
  report the same class, or replace a repaired finding with a different class, stop
  patching witnesses: change the representation, the oracle, the claim, or the brief
  before running another round.
- Repairs may correct, remove, or narrow the pull request's content. They must not add
  design scope, mechanisms, inventories, or promises merely to absorb a finding. When a
  correction would need that, reduce the claim and track the rest outside the pull
  request.
- Freshness is a property of the reviewer's context, not the filesystem. Hand a
  reviewer an existing worktree and its warm target only when it is at the exact review
  head, has a known clean baseline, and has no concurrent writer, and paste the output of
  `.venv/bin/python scripts/worktree_status.py` into the brief as the evidence. Unknown
  or not-clean means wait, and free is the probe's best answer rather than a proof: a
  run that takes no lease, `--fast` among them, is caught only by a scan of the
  processes it spawned. A reviewer whose probes mutate tracked source gets its own
  worktree, and you never edit a worktree a reviewer is reading.
- Before spawning a fresh round, retire only your own stale or failed subagent handles;
  a standing reviewer awaiting a fix is neither. If a spawn routes to remote
  infrastructure, errors, or comes back broken, retire it and retry until you have a
  working fresh local subagent, or state that red-team validation is blocked.

## Spec Authority And Design Discipline

### Documentation Authority

For project-level questions, what Chelis is, what it is for, and what the roadmap says:

1. `spec/design/chelis_canonical_reference.md` controls cross-subject architecture and
   project boundaries.
2. For a transferred chapter, its named capability in the pinned `chelis-plans`
   store controls the subject.
3. An untransferred `spec/00-12*.md` chapter controls its subject.
4. `spec/design/chelis_project_plan.md` controls project sequence that a higher
   authority does not define.
5. `spec/design/archive/` is historical reference only.

Language semantics belong in the numbered spec documents. A chapter transfers only
through a reviewed change that records the transfer; no chapter has transferred, so the
numbered chapters control and the pinned store's captured `chelis-*` capabilities
are reference. If active documents disagree, correct the document that controls the subject. Do not add a
third explanation.

### Normative Specs Are Timeless Contracts

A numbered chapter, a controlling capability spec, and every normative `spec.md` delta
under an active OpenSpec change describe the decided architecture and semantics,
irrespective of how completely any compiler version implements them.

- No project or implementation status in normative specs: no status banners, phase or
  milestone labels, completion claims, delivery histories, PR inventories, oracle
  results, temporary workarounds, or descriptions of what the implementation happens
  to do today.
- State the fully decided rule without weakening it to match a bug, an incomplete
  backend, or a temporary restriction. Never narrow an operation to one dtype because
  that is the only dtype a lane implements today. The implementation moves toward the
  spec; the spec never moves toward bad behavior.
- When an implementation gap would materially mislead a reader, one short
  non-normative parenthetical may say the requirement is not fully implemented and
  link its owning issue. It must not describe the workaround or qualify the rule.
- Sequencing and status live in `spec/design/`, `docs/`, GitHub trackers, or OpenSpec
  proposals, designs, and tasks.

### Numbered Specs Decide; Design Docs Implement

- `spec/00-12*.md` is the authority on WHAT the language does and HOW it must behave:
  semantics, types, dtypes, syntax, effects, op behavior, diagnostics, every
  user-visible contract. `spec/registry/` files are numbered-spec-tier content
  incorporated by reference into their owning `[05-OP-N]` atom, amended under the same
  review discipline.
- `spec/design/*.md` is the authority on how we IMPLEMENT and SEQUENCE those decisions.
  A design doc may elaborate a rule and record its reasoning, but it does not decide one.
- Where the two disagree, the numbered spec wins and the design doc has a bug. Say so in
  the doc rather than reconciling silently in code. When a design doc states a rule that
  is really a language decision, lift it into the numbered spec and leave a pointer.
- Watch for permission-to-mandate escalation. "X is a conforming implementation" in a
  spec does not license "therefore we do X" in a design doc, nor "we do X everywhere" in
  code. If your implementation needs a stronger rule than the spec states, amend the spec
  first and say so in the PR.
- A design doc is not correct merely because it was written down. Before implementing
  it, test its claims against the controlling spec, hardware and ecosystem reality, and
  Chelis's stated principles. If it is wrong, over-broad, or drifted, amend the
  controlling document and tracker before writing code.
- Where the spec leaves a real choice, the tenets above decide it: explicit spelling
  over contextual inference, and the structural design over the patch. If a design doc
  permits both, amend it to select the structural contract before implementing. This
  bias never overrides a normative semantic rule; amend that rule first when the
  language decision must change.

### Public-Surface Change Rule

When behavior changes, update the owning code, tests, docs, and examples in the same
change set: parser, type system, IR, and backend tests; CLI integration tests; the
executable examples in `examples/`; and the active specs and current-state docs. The
[`spec-sync` skill](agent-skills/spec-sync/SKILL.md) walks the surfaces.

## Change Hygiene

- **Changelog fragments.** A behavior-changing PR adds a fragment in `changelog.d/`
  named `<pr-or-slug>.<added|changed|fixed>[.breaking].md`; correct a pending fragment
  when follow-up work changes its claim. Internal work may use the `no-changelog` label.
  Reserve `CHANGELOG.md` edits for release assembly: the release author runs
  `.venv/bin/python scripts/changelog.py build --version VERSION --date YYYY-MM-DD`,
  reviews the preview, repeats with `--write`, and commits the notes, fragment
  deletions, and version bump together, never recreating `[Unreleased]`.
  [The fragment contract](changelog.d/README.md) owns the format.
- **Commit messages.** Plain conventional commits with the configured human author. No
  `Claude-Session` trailers, Codex or Claude attribution, AI co-authorship markers, or
  AI-session links in commit messages or PR bodies. The tracked commit-msg hook rejects
  them; `README.md` explains how it is installed.
- **Issues are closed manually.** Automatic closure is disabled: `Closes #N` in a PR body
  or commit has no effect, and merging never closes an issue. Close one deliberately
  with `gh issue close N --comment "resolved by #<PR>"` once the behavior is confirmed
  on current `main`. Write `Part of #N` or `Addresses #N` when a PR advances an issue
  without finishing it. Close a tracking hub only when every sub-issue is closed and the
  condition the hub names is met.
- **Contract invariants.** Express machine-facing contracts as invariants and lock them
  with tests: perfect success means an empty error list, formatter output stays
  parseable, decompiler output round-trips, executable examples stay executable after
  canonical formatting, status docs claim no more than the repo proves.
- **Manual gates.** Every manual acceptance gate has a documented command, expected
  success condition, and owning phase in [`docs/manual_gates.md`](docs/manual_gates.md);
  if default CI does not run it, the docs say so. Ignored tests are allowed only when
  they clearly mirror a documented manual gate or an environment-dependent prerequisite.
- **CLI surface.** Commands are product surface, not wrappers around library tests. Test
  formatter, decompiler, evaluator, checker, and build behavior against a corpus, and
  test machine-facing output for both shape and semantic invariants. The
  [`cli-surface` skill](agent-skills/cli-surface/SKILL.md) has the corpus rules.

## Issue Tracking

Agents file many issues; use the [`issue-resolution` skill](agent-skills/issue-resolution/SKILL.md)
when picking one up.

- A recurring defect class gets **one tracking issue**, which is also the GitHub
  sub-issue parent for every instance. Its body carries the plan; its evidence lives in
  the owning design doc or `docs/investigations/`. Set the parent link explicitly;
  `Part of #N` in a body creates none.
- Before filing, check whether the issue belongs under an existing tracking issue. Not
  every issue needs a parent.
- An issue has one parent. When a defect splits across classes, parent it to the class
  whose oracle turns green when it is fixed, and add an explicit `Also part of #N` line
  for the other.
- A class without a design doc is legitimate; say so in the tracker.
- `-label:tracking` is the work queue. Prefer the specific label: an issue labelled only
  `soundness` is not findable by anyone who does not already know it exists.

| label | means |
|---|---|
| `tracking` | a hub: a class or a plan, not a work item |
| `bug` | something is not working |
| `soundness` | semantics divergence, type-safety, or a wrong answer; not CI tooling |
| `spec-gap` | normative text was never authored |
| `design-discussion` | the decision exists and is contested, or a design wart |
| `enhancement` | new feature or request (`feature request` is a legacy duplicate) |
| `usability` | developer or user experience |
| `documentation` | docs additions or corrections |
| `failing-on-main` | red on main outside the per-PR checks, nightly- or dispatch-owned; open means still red |
| `nightly-failure` | a nightly workflow failure |
| `no-changelog` | internal change; suppresses only the missing-fragment check |
| `area:eval` | the `chelis eval` interpreter lane |
| `area:runtime` | `chelis-runtime` and the C ABI surface |
| `area:backend` | backend codegen: C, HIP, Metal, and IR lowering |
| `area:prove` | `chelis-prove`, SMT, contract discharge |
| `area:bindings` | Python bindings and the compiler-api embedding surface |
| `area:ecosystem` | shell repos, `reef conform`, ecosystem drift |
| `area:perf` | performance and benchmarking |
| `area:ci` | CI workflows, coverage, mutation testing, dev infrastructure |
| `type-system`, `cli`, `lint` | the type system, the CLI surface, and `chelis-lint` rules |
| `launch:p1` / `launch:p2` / `launch:p3` | launch triage: core promise silently false; loud core failure that ships as a known issue; roughness that does not gate launch |
| `launch:required` | a non-defect launch deliverable or authored decision |
| `demo-path` | breaks a release corpus case; gates launch regardless of priority |
| `fence-ok` | a typed documented rejection is an acceptable P1 resolution |
| `freeze` | a public contract decision that must be authored before launch |
| `scope:core` / `scope:experimental` / `scope:unreleased` | covered by the 0.19 core promise; ships as experimental; outside the public 0.19 release |

## Environment And Tooling

### Worktree And Branch Discipline

- The primary checkout (the main worktree in `git worktree list --porcelain`) is live
  developer state. Read-only queries are fine there; never switch branches, edit, build,
  or create scratch artifacts in it.
- Create a dedicated worktree before the first write of every task, including small
  documentation edits and throwaway probes, and give it its own `.venv` with
  `uv venv --python 3.11`; never copy or symlink another checkout's `.venv`.
- A worktree isolates the working tree, the index, and its HEAD reflog. The stash
  stack, `.git/info/exclude`, the hooks directory, and branch reflogs are shared by
  every worktree on the clone. Do not run `git stash` in a shared clone: to discard your
  own changes use `git checkout -- <paths>`; to park them, copy the files to task-owned
  scratch space or commit them on your branch.
- Do not repurpose an unrelated worktree because it appears idle. Reuse only for the
  same PR or immediate follow-up after checking ownership, exact head, status, and active
  processes. Never share a worktree with a reviewer while either of you writes to it.
- After a PR merges, remove its worktree and task-owned target with individual
  `git worktree remove <path>` and `cargo clean --target-dir <path>` commands, never a
  blanket loop, after confirming the PR is merged, nothing uncommitted is worth keeping,
  and no process owns the target. Squash merges mean "commits ahead of `origin/main`"
  proves nothing; compare patch ids when in doubt. Branch deletion is a separate decision.

## Subagents

[`docs/investigations/agent_contract_rationale.md`](docs/investigations/agent_contract_rationale.md)
holds the measurements behind these rules.

- Every subagent prompt names the delivery mechanism and the complete expected report.
  A report that is not sent through the platform's final-report channel has not been
  delivered. A subagent never ends its turn merely to wait for a background build or
  notification that cannot wake it: keep ownership through a synchronous wait, or return
  an honest partial result. A reviewer that has delivered its round report is not
  waiting; it stays available for the orchestrator to resume with the fix.
- CI is watched by at most one background waiter whose exit wakes the session, or by
  nobody. Never watch CI from a foreground sleep or poll loop.
- If an agent returns "waiting" or goes idle without the deliverable, resume it
  immediately with the exact missing items. Prefer a labelled partial report over
  silence or an overstated completion claim, and deduplicate repeated reports that
  race with a resume nudge.
- More than five subagents live at once under one orchestrator needs the user's
  explicit approval and a stated reason. Five is the widest fan-out measured working
  here, not a certified safe width, and it is a separate budget from the CPU one above.
- Every spawn names its model tier and says in one clause why that tier fits: the
  expensive tier for judgement whose errors are costly to detect, the cheap tier for
  mechanical work such as waiting on CI, polling, or transcribing a result. The
  orchestrator states its own context size in the message that announces a spawn.
- Every brief states a numeric report-length budget, and a numeric context budget except
  for red-team rounds. An agent that will exceed its context budget says so and returns
  what it has.
- A brief says which facts the orchestrator has already verified, against what head, and
  that the agent must not re-derive them, and it names what the agent still has to
  establish itself.
- A brief longer than a few paragraphs is a file passed by absolute path, stored where
  it outlives both the agent and the session, never in a per-session scratchpad.
  Inter-agent messages truncate silently near four kilobytes. "Inline" means
  self-contained, the opposite of "read `AGENTS.md`", not pasted into the spawn message.
- Reports come back the same way: the agent writes the report to a file and replies with
  the absolute path and a one-line summary. That reply is the delivery.
- A subagent that reuses a worktree restores its temporary probes and reports the final
  worktree status unless asked to retain them. Before a heavyweight cargo command it
  reports the exact command and expected weight to the orchestrator.

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
default. Python is uv-managed. See the managed block above for the upstream contract.

**Divergence — CI does not use `chelisup`.** `conform audit` reports row 5
(`toolchain-installer`) as MANUAL here, and the honest answer is that CI installs
the toolchain by unpacking the release tarball into the image rather than through
a pin-resolving installer. That is the point of the Docker shell: the image *is*
the pin, it is built fresh on every bump (`no-cache: true`), and a stale binary
cannot survive a `CHELIS_VERSION` change because that ARG is a build-arg. Use
`chelisup` for local work; do not add it to the image.

The image in [`docker/Dockerfile`](docker/Dockerfile) is the authoritative
execution environment: it downloads `chelis-v<version>-linux-x86_64.tar.gz` from
the chelis release and installs the shell releases into the Reef registry. When
you bump the pin, `ARG CHELIS_VERSION` in the Dockerfile, the `build-args:` block
in [`ci.yml`](.github/workflows/ci.yml), the `image:` tag in
[`docker-compose.yml`](docker/docker-compose.yml), and `env.CHELIS_VERSION` in
[`release.yml`](.github/workflows/release.yml) all move together. `conform bump`
rewrites the reef and release-workflow pins only; the three Docker-lane locations
are this repo's own and are checked by hand.

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

- `python3 scripts/regen_deep.py` after any `.ch` edit (the committed `.dp`
  sidecars are byte-compared in CI).
- `python3 scripts/regen_octant.py` when the octant pin moves or the Surf
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
