let parseOnly = ref false in
let main =
   let speclist = [("--parse-only", Arg.Set parseOnly, "Enables parse only mode")]
   in
   let usageMessage = "Petitghc is a small compile for a subset of the Haskell language: call with ./petitghc filename or ./petitghc --parse-only filename" in
   Arg.parse speclist parseFile usageMessage

let () = main
