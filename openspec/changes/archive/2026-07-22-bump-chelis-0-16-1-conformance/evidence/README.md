# Implementation evidence

## Baseline conformance (`=0.14.0`)

- Deterministic binary: `~/.chelis/toolchains/0.16.1/bin/chelis`
- Observed version: `chelis 0.16.1`
- Audit command: `~/.chelis/toolchains/0.16.1/bin/chelis reef conform audit --json`
- Expected audit exit: `1`
- Result: `8` MUST failures at Reef pin `=0.14.0`
- Raw JSON Lines: [`baseline-conform-audit-0.14.0.json`](baseline-conform-audit-0.14.0.json)

## Conformance retrofit ownership

`conform init` was run in-place with the deterministic `0.16.1` binary. Its generic replacements for `.github/workflows/ci.yml` and `reef.toml`, plus the unrelated `src/main.ch` starter, were removed so the existing learner CI, package version, dependency declarations, and corpus entry points remain authoritative until their scoped tasks.

Toolchain-owned material is limited to the fenced managed blocks, `agent-skills/` bodies and `UPSTREAM.toml`, `.claude/skills` and `.codex/skills` links, and the generated bump workflow shape. Repository-owned material includes prose outside managed fences, capability rows, upstream reprobe records, learner fixtures, and acceptance jobs. The pre-retrofit repository had no local skill, so `[conform].local_skills` is intentionally not declared. `conform sync` was not run while `reef.toml` remained pinned to `=0.14.0`.

## Dependency-closure blocker

After updating Coral to `0.7.31` and Nautilus to `0.7.34`, a clean lock regeneration auto-fetched `school` `0.1.9` and failed with `package.compiler must be '=0.16.1' in 'school'`. School PR #175 had merged the `0.16.1` / package `0.1.10` bump without a corresponding release. On 2026-07-22, School `v0.1.10` was built from commit `3a3b0039d6d008779a1d2b4a313772313a5ea648`, passed `conform audit --explain` and `reef build`, and was published with both Reef assets. A fresh `hello-chelis` lock regeneration then auto-fetched the release and built successfully. The resulting closure is Chelis Std `0.4.0`, Coral `0.7.31`, Nautilus `0.7.34`, and School `0.1.10`, all declaring compiler `=0.16.1`.

## Final acceptance

See [`final-validation.md`](final-validation.md) for the no-cache image
manifests, lane-by-lane counts, conformance verdicts, and adversarial-review
disposition.
