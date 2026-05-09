module Hello.Basics.ModulesAndImports.Main
import Hello.Basics.ModulesAndImports.Util (..)
export (boost)
def boost() -> tensor[n, f32] = ones3() |> double |> double
