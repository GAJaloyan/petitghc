module L = Lexing
module E = Error

(* parseFile : string -> Ast.file * int
 * Returns the ast associated the code in the file named filename and 
 * the possible exit code *)
let parseFile filename =
    try begin 
        let lexbuf = L.from_channel (open_in filename) in
        try begin
            lexbuf.L.lex_curr_p <- 
                { lexbuf.L.lex_curr_p with L.pos_fname = filename };
            (Parser.file Lexer.lexer lexbuf,0)
        end with
        | Lexer.LexingError -> 
            let pos1 = L.lexeme_start_p lexbuf
            and pos2 = L.lexeme_end_p lexbuf in
            Format.eprintf "%aLexical error.@." E.print_location (E.Loc(pos1,pos2));
            ([],1)
        | Parser.Error -> 
            let pos1 = L.lexeme_start_p lexbuf
            and pos2 = L.lexeme_end_p lexbuf in
            Format.eprintf "%aSyntax error.@." E.print_location (E.Loc(pos1,pos2));
            ([],1)
        | Lexer.SyntaxError s ->
            let pos1 = L.lexeme_start_p lexbuf
            and pos2 = L.lexeme_end_p lexbuf in
            Format.eprintf "%aSyntax error: " E.print_location (E.Loc(pos1,pos2));
            Format.eprintf "%s.@." s;
            ([],1)
    end with
    | Sys_error _ ->
        Format.eprintf  "File %s could not be read" filename;
        ([],2)
    | _ ->
        Format.eprintf "Internal error";
        ([],2)

let parseOnly = ref false
let typeOnly = ref false 

let parseFileExit filename =
    let (ast, code) = parseFile filename in
    if !parseOnly || code <> 0 then
        exit code
    else begin
        Printf.printf "dummy\n";
        exit 0
    end

let main =
   let speclist =
       [("--parse-only", Arg.Set parseOnly, "Enables parse only mode");
        ("--type-only" , Arg.Set typeOnly , "Enables type inference only mode")]
   in
   let usageMessage = 
       "Petitghc is a small compiler for a subset of the Haskell language: \
        call with ./petitghc filename or ./petitghc --parse-only filename" in
   Arg.parse speclist parseFileExit usageMessage

let () = main
