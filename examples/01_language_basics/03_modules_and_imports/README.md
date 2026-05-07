# Multi-file modules and imports

Three import forms in one example:

1. `import Std.Tensor.Construct (..)` — bring everything exported into
   unqualified scope.
2. `import Std.Tensor.Reduce (sum, mean)` — bring named items only.
3. `import Std.Math` — qualified-only access; you must say `Std.Math.exp`.

`util.ch` declares a small helper module. `main.ch` imports from it three
ways and uses each.

Both files declare their `module` line as the first non-comment line, and
the file paths match: `Hello.Basics.Mods.Util` lives at
`hello/basics/mods/util.ch` (relative to project root).
