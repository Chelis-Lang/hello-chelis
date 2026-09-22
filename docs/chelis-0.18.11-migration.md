# Chelis 0.18.11 candidate

Prepared 2026-09-21 in the isolated `chore/chelis-0.18.11` worktree. The
existing unreleased package candidate remains hello-chelis 0.1.11. Reef,
release-workflow, Docker ARG, CI build-argument and Compose image pins target
Chelis 0.18.11; an explicit `reef conform sync` refreshed managed artifacts.

All 93 maintained Surf files passed `chelis migrate surf --from 0.18
--inplace` after explicit dimension binders were added to formerly inferred
`n` signatures. The linearity example's `residual` definition conflicted with
the standard prelude macro; its export and test call now use `double_shared`.
The existing script regenerated all 89 Deep sidecars from their Surf sources
using the supplied preparation compiler.

`chelis reef build` stops with `invalid shell envelope: unsupported
predecessor shell format`. Existing published dependency/lock entries remain
unchanged. Finalize Nautilus, Coral and School pins only after compatible
releases publish. The Docker-installed Octant and c-earchin artifacts also
require their own published-compatibility check.

`scripts/regen_octant.py` currently exits `octant not on PATH`; generated
Octant triples must be regenerated using the compatible released translator.
The complete Docker CI gate, executable tests, negative diagnostic-kind oracle,
lowering checks and capability re-probes remain outstanding. Do not claim this
leaf closes the cascade until those gates pass against published assets.
