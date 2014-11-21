open Parser
open Lexer
open Lexing
open Error

let parseFile filename =
    let lexbuf = Lexing.from_channel (open_in filename) in
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
    try begin 
        let ast = file lexer lexbuf in
        exit 0
    end with
    | Lexer.LexingError -> 
        let pos1 = Lexing.lexeme_start_p lexbuf
        and pos2 = Lexing.lexeme_end_p lexbuf in
        Format.eprintf "%aLexical error.@." print_location (Loc(pos1,pos2));
        exit 1
        (*Printf.printf ("File \"%s\", line %d, characters %d-%d\nlexical error\n") filename pos.pos_lnum pos.pos_cnum  (1 + pos.pos_cnum); exit 1*)
    | Parser.Error -> 
        let pos1 = Lexing.lexeme_start_p lexbuf
        and pos2 = Lexing.lexeme_end_p lexbuf in
        Format.eprintf "%aSyntax error.@." print_location (Loc(pos1,pos2));
        exit 1
    | _ -> exit 2

let parseOnly = ref false

let main =
   let speclist = [("--parse-only", Arg.Set parseOnly, "Enables parse only mode")]
   in
   let usageMessage = "Petitghc is a small compiler for a subset of the Haskell language: call with ./petitghc filename or ./petitghc --parse-only filename" in
   Arg.parse speclist parseFile usageMessage

let () = main
