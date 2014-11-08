type token =
    | Eof
    | If
    | Then
    | Else
    | Assign
    | LeftCurly
    | RightCurly
    | LeftBracket
    | RightBracket
    | LeftPar
    | RightPar
    | Plus
    | Minus
    | Time
    | Greater
    | GreaterEq
    | Lower
    | LowerEq
    | Unequal
    | Equal
    | And
    | Or
    | Colon
    | Return
    | Do
    | Case
    | Of
    | True
    | False
    | Comma
    | Lambda
    | Arrow
    | Semicolon
    | Let
    | In
    | Int of int
    | Ident of string
    | Ident0 of string
    | Char of char
    | String of string
