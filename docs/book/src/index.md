# Learn Chelis

Start with a program that adds two vectors. Change one input, check the result,
and then deliberately give it the wrong shape. The next lessons use the same
small tensors to explain borrowing, numeric precision, and derivatives.

You need a Chelis installation and a text editor. These lessons use standalone
files with no package dependencies. They assume you have written a function
before; they do not assume you know a tensor framework or a functional language.

[Create your first program](getting-started.md), then follow the
[five lessons](curriculum.md). Each lesson includes the source
and a result captured from the compiler, an explanation, and a change to try.

## After the lessons

The [Surf and Deep guide](fundamentals.md) shows how the compiler
represents your function. [Read a larger calculation](capstones.md)
applies them to linear regression, Black-Scholes pricing with Greeks, and
returns and risk statistics.

The accompanying [hello-chelis repository](https://github.com/Chelis-Lang/hello-chelis)
packages larger examples as modules. A module defines and exports functions
but does not call them, so evaluating one shows no result. The capstone page
gives each key function's signature and body, and a short file that imports
it, calls it, and prints the result.

The repository is [MIT licensed](https://github.com/Chelis-Lang/hello-chelis/blob/main/LICENSE).
