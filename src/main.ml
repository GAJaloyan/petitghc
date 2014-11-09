open Parser
open Lexer
open Lexing

let parseFile filename =
    let lexbuf = Lexing.from_channel (open_in filename) in
    try begin 
        let ast = file lexer lexbuf in
        exit 0
    end with
    | Lexer.LexingError -> Printf.printf ("File \"%s\", line %d, characters \nlexical error\n") filename lexbuf.lex_curr_p.pos_lnum; exit 1

let parseOnly = ref false

let main =
   let speclist = [("--parse-only", Arg.Set parseOnly, "Enables parse only mode")]
   in
   let usageMessage = "Petitghc is a small compile for a subset of the Haskell language: call with ./petitghc filename or ./petitghc --parse-only filename" in
   Arg.parse speclist parseFile usageMessage

let () = main
