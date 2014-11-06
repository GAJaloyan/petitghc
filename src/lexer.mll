{
    open Tokens
    exception LexingError

    let char_of_car s =
        if String.length s = 1 then s.[0]
        else match s.[1] with
        | 'n'  -> '\n'
        | 't'  -> '\t'
        | '"'  -> '"'
        | '\\' -> '\\'
        | _    -> raise LexingError
}

let digit = ['0'-'9']
let car   = ['\032'-'\033' '\035'-'\091' '\093'-'\126'] | "\\\\" | "\\\"" | "\\n" | "\\t"
let empty = ['\n' '\t' ' ']
let lower = ['a'-'z']
let alpha = ['a'-'z' 'A'-'Z']

rule lexer = parse
| empty+                { lexer lexbuf }
| eof                   { Eof }
| "--" [^'\n']* '\n'?   { lexer lexbuf }
| "if"                  { If }
| "then"                { Then }
| "else"                { Else }
| "="                   { Assign }
| "{"                   { LeftCurly }
| "}"                   { RightCurly }
| "["                   { LeftBracket }
| "]"                   { RightBracket }
| "("                   { LeftPar }
| ")"                   { RightPar }
| "+"                   { Plus }
| "-"                   { Minus }
| "*"                   { Time }
| ">"                   { Greater }
| ">="                  { GreaterEq }
| "<"                   { Lower }
| "<="                  { LowerEq }
| "/="                  { Unequal }
| "=="                  { Equal }
| "&&"                  { And }
| "||"                  { Or }
| ":"                   { Colon }
| "return"              { Return }
| "do"                  { Do }
| "case"                { Case }
| "of"                  { Of }
| "True"                { True }
| "False"               { False }
| ","                   { Comma }
| "\\"                  { Lambda }
| "->"                  { Arrow }
| ";"                   { Semicolon }
| "let"                 { Let }
| "in"                  { In }
| digit+ as inum        { Int (int_of_string inum) }
| '\'' (car as c) '\''  { Char (char_of_car c) }
| '"' (car* as str) '"' { String str }
| (lower (alpha | '_' | '\'' | digit)*) as id { Ident id }
| _                     { raise LexingError }
