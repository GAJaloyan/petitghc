let parseFile filename =
    let lexbuf = Lexing.from_channel (open_in filename) in
    lexbuf.Lexing.lex_curr_p <- { lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = filename };
    try begin 
        let ast = Parser.file Lexer.lexer lexbuf in
        0
    end with
    | Lexer.LexingError -> 
        let pos1 = Lexing.lexeme_start_p lexbuf
        and pos2 = Lexing.lexeme_end_p lexbuf in
        Format.eprintf "%aLexical error.@." Error.print_location (Error.Loc(pos1,pos2));
        1
    | Parser.Error -> 
        let pos1 = Lexing.lexeme_start_p lexbuf
        and pos2 = Lexing.lexeme_end_p lexbuf in
        Format.eprintf "%aSyntax error.@." Error.print_location (Error.Loc(pos1,pos2));
        1
    | _ -> 2

let parseOnly = ref false

let parseFileExit filename =
    exit (parseFile filename)

let main =
   let speclist = [("--parse-only", Arg.Set parseOnly, "Enables parse only mode")]
   in
   let usageMessage = "Petitghc is a small compiler for a subset of the Haskell language: call with ./petitghc filename or ./petitghc --parse-only filename" in
   Arg.parse speclist parseFileExit usageMessage

let () = main
