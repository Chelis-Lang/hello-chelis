---
name: phase-gate
description: Use when deciding whether a Chelis phase is actually complete. Applies the repo’s completion standard, checks manual gates, examples, docs, and phase-specific acceptance criteria before any completion claim.
---

# Phase Gate

Use this skill when a phase is claimed complete or nearly complete.

## Acceptance Oracle

Before judging a phase, identify its single authoritative oracle:

- one command
- one named suite
- or one documented manual validation runner

Treat all other evidence as supporting material, not the completion decision itself.

## Completion Rule

Do not call the phase complete if any of these remain:

- broken default gate
- missing or ambiguous phase oracle
- hidden manual-only acceptance criteria not documented as such
- false-perfect machine-facing reports
- examples/docs whose meaning contradicts the actual implementation
<!-- shell-local:begin -->
<!-- shell-local:exclude:begin -->
<!-- ## Default Gate -->
<!-- ## Additional Required Checks -->
<!-- shell-local:exclude:end -->

## Hello-Chelis Gate And Acceptance Oracle

The shell's default repository gate is the `corpus` job in
`.github/workflows/ci.yml` on the exact candidate head. It builds the pinned
Docker image and runs `chelis reef conform bump-check --base origin/main`,
`chelis reef conform audit`, `chelis lint --check .`,
`chelis check src/basics/hellotensor.ch`, `chelis test tests/ --jobs auto`,
the `tests_neg` and `tests_blocked` expectation suites, and
`uv run --frozen --group test pytest -q tests/`. The required fallback jobs
also need terminal success. Locally, run `chelis reef conform audit` and the
focused checks for changed paths before pushing; they do not replace the
Docker corpus result.

For a claim that the teaching corpus or one of its milestones is complete,
name the applicable scope and acceptance oracle first. The `corpus` job is
the repository-wide integration oracle; a narrower milestone also needs its
documented acceptance checks from this shell's plan or tests. If no
milestone oracle is documented, do not claim that milestone complete. Check
that blocked cases, manual gates, examples, and current-state docs match the
scope of the claim.
<!-- shell-local:end -->
