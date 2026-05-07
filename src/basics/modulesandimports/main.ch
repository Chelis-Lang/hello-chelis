module Hello.Basics.ModulesAndImports.Main

-- Form 1: glob — pull every export into unqualified scope.
import Hello.Basics.ModulesAndImports.Util (..)

export (boost)

-- ones3() and double() came in via the glob import above.
-- Pipe form keeps the data flow left-to-right.
def boost() -> tensor[n, f32] =
  ones3() |> double |> double
