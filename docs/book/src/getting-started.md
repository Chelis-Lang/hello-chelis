# Your first program

## Install and open a folder

Follow [Get started](https://chelis.ch/get-started) to install the current Chelis release. Check
that your terminal can find it:

```sh
chelis --version
```

Create a new, empty folder for the lessons. Keep it outside any existing Chelis
project, including a hello-chelis checkout. A project's `reef.toml` can select
a compiler version and make commands check the surrounding package.

```sh
mkdir chelis-lessons
cd chelis-lessons
```

## Add two vectors

Create `addition.ch` in your editor and paste this source:

```chelis
def add_vec[n](x: &tensor[n, f32], y: &tensor[n, f32]) -> tensor[n, f32] = add(x, y)
x = to_tensor([1.0f32, 2.0f32, 3.0f32])
y = to_tensor([4.0f32, 5.0f32, 6.0f32])
answer = add_vec(x, y)
```

`chelis eval --file addition.ch`:

```text
x = tensor(shape=[3], data=[1.0, 2.0, 3.0])
y = tensor(shape=[3], data=[4.0, 5.0, 6.0])
answer = tensor(shape=[3], data=[5.0, 7.0, 9.0])
```

The first line defines `add_vec`. The next two lines bind `x` and `y` to
three-element tensors. The final line calls the function and binds its result
to `answer`. These top-level bindings are what make this file a calculation
you can run.

Run the commands from your lesson folder:

```sh
chelis fmt --inplace addition.ch
chelis check addition.ch
chelis eval --file addition.ch
```

`fmt` formats the source. `check` checks the program without evaluating it;
the report's `errors` list should be empty. `eval` runs it and displays its
top-level values. Find `answer` in the result above. Its elements come from
adding the two inputs position by position.

Change the first element of `y` from `4.0f32` to `10.0f32`. Run `check` and
`eval` again. Only the first element of `answer` should change, from five to
eleven. If nothing changes, check that you saved the file and are running it
from the folder you created.

## Optional: build an executable

To run this program as native code, install the compiler tools described in
[Install](https://chelis.ch/docs/chelis/install/), then run:

```sh
chelis build addition.ch --output target/addition
./target/addition/addition
```

`build` invokes the native compiler and puts the executable in the output
directory. It checks formatting and lint rules first. Run `fmt --inplace`
again after an edit if the build reports a formatting error. You do not need
to build an executable to follow the lessons.

Continue with [shapes, reuse, precision, and derivatives](curriculum.md).
