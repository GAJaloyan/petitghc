module L = Lexing
module E = Error

(* parseFile : string -> Ast.file * int
 * Returns the ast associated the code in the file named filename and 
 * the possible exit code *)
let parseFile filename =
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
    | _ ->
        Format.eprintf "Internal error";
        ([],2)

let parseOnly = ref false
let typeOnly = ref false 

let treatsFileExit filename =
    let (ast, code) = parseFile filename in
    if !parseOnly || code <> 0 then
        exit code
    else begin
        try Type.infer ast;
        if !typeOnly then
            exit 0;
        let ast' = GenCode.compile_program "outfile.s" Make_closures.transform (Simplify.simplify ast) in
        exit 0
        with
        | E.SyntaxError s ->
            (Format.eprintf "Syntax error: ";
            Format.eprintf "%s.@." s;
            exit 1)
        | E.SemantError s ->
            (Format.eprintf "Error: ";
            Format.eprintf "%s.@." s;
            exit 1)
        | Type.UnificationFailure (t1,t2,(pos1,pos2)) ->
            (Format.eprintf "%aTyping error. The error lies in %s <> %s@." E.print_location (E.Loc(pos1,pos2))
                                                     (Type.type_to_string t1)
                                                     (Type.type_to_string t2);
            exit 1)
    end

let main =
   let speclist =
       [("--parse-only", Arg.Set parseOnly, "Enables parse only mode");
        ("--type-only" , Arg.Set typeOnly , "Enables type inference only mode")]
   in
   let usageMessage = 
       "Petitghc is a small compiler for a subset of the Haskell language: \
        call with ./petitghc filename or ./petitghc --parse-only filename" in
   Arg.parse speclist treatsFileExit usageMessage

let () = main
