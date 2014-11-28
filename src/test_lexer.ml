open Parser
let string_of_token = function
    | Parser.Eof           -> "Eof"
    | If            -> "If"
    | Then          -> "Then"
    | Else          -> "Else"
    | Assign        -> "Assign"
    | LeftCurly     -> "LeftCurly"
    | RightCurly    -> "RightCurly"
    | LeftBracket   -> "LeftBracket"
    | RightBracket  -> "RightBracket"
    | LeftPar       -> "LeftPar"
    | RightPar      -> "RightPar"
    | Plus          -> "Plus"
    | Minus         -> "Minus"
    | Time          -> "Time"
    | Greater       -> "Greater"
    | GreaterEq     -> "GreaterEq"
    | Lower         -> "Lower"
    | LowerEq       -> "LowerEq"
    | Unequal       -> "Unequal"
    | Equal         -> "Equal"
    | And           -> "And"
    | Or            -> "Or"
    | Colon         -> "Colon"
    | Return        -> "Return"
    | Do            -> "Do"
    | Case          -> "Case"
    | Of            -> "Of"
    | True          -> "True"
    | False         -> "False"
    | Comma         -> "Comma"
    | Lambda        -> "Lambda"
    | Arrow         -> "Arrow"
    | Semicolon     -> "Semicolon"
    | Let           -> "Let"
    | In            -> "In"
    | Int n         -> "Int " ^ string_of_int n
    | Ident id      -> "Ident " ^ id
    | Ident0 id     -> "Ident0 " ^ id
    | Char c        -> "Char " ^ Char.escaped c
    | String s      -> "String " ^ s

let test_file tfile = 
    try
    let lexbuf = Lexing.from_channel (open_in tfile) in
    Printf.printf "%s\n" tfile; 
    let rec print_code lexbuf =
        let t = Lexer.lexer lexbuf in
        print_endline (string_of_token t);
        if t <> Eof then print_code lexbuf in
    print_code lexbuf
    with _ -> ()

let goodFiles =
    [ "tests/syntax/good/testfile-comment-1.hs";
      "tests/syntax/good/testfile-semicolon-1.hs";
      "tests/syntax/good/testfile-semicolon-2.hs";
      "tests/syntax/good/testfile-semicolon-3.hs";
      "tests/syntax/good/testfile-string-1.hs"
    ]

let badFiles =
    [ "tests/syntax/bad/testfile-character_literal-1.hs";
      "tests/syntax/bad/testfile-do-1.hs";
      "tests/syntax/bad/testfile-lambda-1.hs";
      "tests/syntax/bad/testfile-lexical-1.hs";
      "tests/syntax/bad/testfile-string_literal-1.hs";
      "tests/syntax/bad/testfile-string_literal-2.hs";
      "tests/syntax/bad/testfile-string_literal-3.hs";
    ]

let main () =
    Printf.printf "No error should happen\n";
    Printf.printf "%s\n"( Sys.getcwd ());
    flush stdout;
    List.iter test_file goodFiles;
    Printf.printf "Errors should be signaled\n";
    flush stdout;
    List.iter test_file badFiles

let () = main()
