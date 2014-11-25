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

let lexbuf = Lexing.from_channel (open_in Sys.argv.(1))

let rec print_code lexbuf =
    let t = Lexer.lexer lexbuf in
    print_endline (string_of_token t);
    if t <> Eof then print_code lexbuf

let () = print_code lexbuf
