# `c-earchin/`: requirements to proofs

c-earchin translates requirements written in EARS (the "Easy Approach to
Requirements Syntax") into Chelis Deep property witnesses, which
`chelis prove` then checks. The example here is a small set of finance
rules, readable in under a minute:

- [`options_rules.ears`](finance_options/options_rules.ears): one ubiquitous
  requirement plus `WHEN`, `WHILE`, `IF ... THEN`, `WHERE`, and one complex
  requirement;
- [`options_rules.dp`](finance_options/options_rules.dp): the generated
  witnesses, one Chelis property per requirement;
- [`options_rules.spans.json`](finance_options/options_rules.spans.json):
  provenance from each property back to its EARS line;
- [`options_rules_fail.dp`](finance_options/options_rules_fail.dp): the same
  witnesses with the portfolio-delta rule deliberately broken.

## Run it

From the repo root:

```sh
chelis prove c-earchin/finance_options/options_rules.dp \
  --spans c-earchin/finance_options/options_rules.spans.json \
  --json
```

All six properties pass. The broken variant fails, and the diagnostic points
at the requirement's source line:

```sh
chelis prove c-earchin/finance_options/options_rules_fail.dp \
  --spans c-earchin/finance_options/options_rules.spans.json
```

```text
property failure: req_FIN_003
  --> references/finance_options/options_rules.ears:3:1 FIN-003
  | WHILE the exchange is open, the portfolio delta shall be at most the limit.
```

The path in the diagnostic is where the file lives in the c-earchin
repository, because the spans were generated there.

## Why these files are copied from the release

The fixtures are byte-for-byte copies from the c-earchin v0.3.5 release
source, and [`provenance.json`](finance_options/provenance.json) records the
release commit and a SHA-256 for each file.
[`tests/test_c_earchin_artifacts.py`](../tests/test_c_earchin_artifacts.py)
checks those hashes, then runs both proofs above.

They are copied rather than regenerated because c-earchin does not publish a
command-line binary this repo could run, and the c-earchin Reef release
contains the library, not these reference fixtures.

## Scope

The bridge verifies resolved, pure-boolean properties. It accepts a full
EARS document, but in non-strict mode a requirement that uses vocabulary it
cannot resolve is marked `recorded_only` and is not emitted as a property;
use `c-earchin translate --strict` for artifacts you intend to verify.
