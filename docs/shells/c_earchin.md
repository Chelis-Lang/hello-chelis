# c-earchin — EARS Requirements Bridge

`c-earchin` translates EARS-style requirements into Chelis Deep property
witnesses. The committed v0.3.2 demo is intentionally finance-flavored so a stakeholder
can read the input in under a minute and see the value:

- a single `.ears` source covering ubiquitous, `WHEN`, `WHILE`,
  `IF ... THEN`, `WHERE`, and one Complex requirement;
- generated `.dp` witnesses with Chelis property metadata;
- `.spans.json` provenance back to the original EARS lines;
- `chelis prove` coverage for both pass and fail cases.

The Docker image installs the released c-earchin package:

```sh
chelis reef install --from-github Chelis-Lang/c-earchin@v0.3.3
```

This repo commits the v0.3.2 finance-options proof fixtures under
[`c-earchin/finance_options/`](../../c-earchin/finance_options/) so CI
does not need to clone or build c-earchin from source. From this repo
root, use:

```sh
chelis prove c-earchin/finance_options/options_rules.dp \
  --spans c-earchin/finance_options/options_rules.spans.json \
  --json
```

The failure fixture deliberately mutates the portfolio-delta rule:

```sh
chelis prove c-earchin/finance_options/options_rules_fail.dp \
  --spans c-earchin/finance_options/options_rules.spans.json
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

For the exact stakeholder contract, read `docs/verification-scope.md`
in the c-earchin v0.3.2 release source.
