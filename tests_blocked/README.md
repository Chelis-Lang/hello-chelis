# Blocked-probe suite

One expected-to-fail reproducer per upstream blocker affecting this corpus
(`<area>/<name>.ch` + `<name>.expect`; line 1 = pinned diagnostic substring,
lines 2+ = the `chelis#NNN` citation + on-pass de-narrowing instructions).
Run with `chelis test tests_blocked/ --expect blocked`.

[`coral/grad_string_key.ch`](coral/grad_string_key.ch) pins chelis#2552: the
host-runtime gradient through a string-keyed frame remains blocked at
`append` lowering. Its [sidecar](coral/grad_string_key.expect) names the
current diagnostic and de-narrowing steps.
