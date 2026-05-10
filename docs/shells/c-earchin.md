# c-earchin — EARS Requirements Bridge

`c-earchin` translates EARS-style requirements into Chelis Deep property
witnesses. The v0.2.1 demo is intentionally finance-flavored so a stakeholder
can read the input in under a minute and see the value:

- a single `.ears` source covering ubiquitous, `WHEN`, `WHILE`,
  `IF ... THEN`, `WHERE`, and one Complex requirement;
- generated `.dp` witnesses with Chelis property metadata;
- `.spans.json` provenance back to the original EARS lines;
- captured `chelis prove` output for both pass and fail cases.

The canonical demo lives in the c-earchin release repo:

```sh
git clone git@github.com:Chelis-Lang/c-earchin.git
cd c-earchin
git checkout v0.2.1

chelis prove references/finance_options/options_rules.dp \
  --spans references/finance_options/options_rules.spans.json \
  --json
```

The failure fixture deliberately mutates the portfolio-delta rule:

```sh
chelis prove references/finance_options/options_rules_fail.dp \
  --spans references/finance_options/options_rules.spans.json
```

The important part is the diagnostic, which resolves the Deep property back to
the EARS author's source line:

```text
property failure: req_FIN_003
  --> references/finance_options/options_rules.ears:3:1 FIN-003
  | WHILE the exchange is open, the portfolio delta shall be at most the limit.
```

## Scope

The v1 bridge verifies resolved pure-boolean property witnesses. It accepts a
full EARS corpus, but unresolved vocabulary in non-strict mode is marked
`recorded_only` and is not emitted as a Chelis proof property. Use
`c-earchin translate --strict` for artifacts you intend to verify.

For the exact stakeholder contract, read
`docs/verification-scope.md` in the c-earchin repo.
