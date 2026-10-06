# Blocked-probe suite

One expected-to-fail reproducer per upstream blocker affecting this corpus
(`<area>/<name>.ch` + `<name>.expect`; line 1 = pinned diagnostic substring,
lines 2+ = the `chelis#NNN` citation + on-pass de-narrowing instructions).
Run with `chelis test tests_blocked/ --expect blocked`.

[`coral/grad_string_key.ch`](coral/grad_string_key.ch) pins chelis#2552: the
host runtime cannot evaluate `grad` through a string-keyed Coral column
lookup. Its [sidecar](coral/grad_string_key.expect) names the diagnostic and
the de-narrowing steps.
