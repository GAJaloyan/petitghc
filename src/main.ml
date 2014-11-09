open Parser
open Lexer
open Lexing

let print_location f1 p1 p2 =
    let n1 = p1.pos_cnum - p1.pos_bol in (* character number *)
    let n2 = p2.pos_cnum - p2.pos_bol in
    let np1 = p1.pos_cnum in (* character position *)
    let np2 = p2.pos_cnum in
    let l1 = p1.pos_lnum in (* line number *)
    let l2 = p2.pos_lnum in
    let lp1 = p1.pos_bol in (* line position *)
    let lp2 = p2.pos_bol in
    let f1 = p1.pos_fname in (* file name *)
    let f2 = p2.pos_fname in
    if l2 > l1 then
        Printf.printf "File \"%s\", line %d-%d, characters %d-%d:\n" f1 l1 l2 n1 n2
    else
        Printf.printf "File \"%s\", line %d, characters %d-%d:\n" f1 l1 n1 n2

let parseFile filename =
    let lexbuf = Lexing.from_channel (open_in filename) in
    lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
    try begin 
        let ast = file lexer lexbuf in
        exit 0
    end with
    | Lexer.LexingError -> let pos = lexbuf.lex_curr_p in
        Printf.printf ("File \"%s\", line %d, characters %d-%d\nlexical error\n") filename pos.pos_lnum pos.pos_cnum  (1 + pos.pos_cnum); exit 1
    | Parser.Error -> 
            let pos1 = Lexing.lexeme_start_p lexbuf
            and pos2 = Lexing.lexeme_end_p lexbuf in
            print_location filename pos1 pos2;
            Printf.printf "syntax error\n"
    | _ -> exit 2

let parseOnly = ref false

let main =
   let speclist = [("--parse-only", Arg.Set parseOnly, "Enables parse only mode")]
   in
   let usageMessage = "Petitghc is a small compile for a subset of the Haskell language: call with ./petitghc filename or ./petitghc --parse-only filename" in
   Arg.parse speclist parseFile usageMessage

let () = main
