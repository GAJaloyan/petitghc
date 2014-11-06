{
    open Tokens
    exception LexingError
}

let digit = ['0'-'9']
let car   = ['\032'-'\126']
let empty = ['\n' '\t' ' ']
let lower = ['a'-'z']
let alpha = ['a'-'z' 'A'-'Z']

rule lexer = parse
| empty+                { lexer lexbuf }
| eof                   { Eof }
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
| digit+ as inum        { Int (int_of_string n) }
| '\'' (car as c) '\''  { Char c.[0] }
| '"' (car* as str) '"' { String str }
| (lower (alpha | '_' | '\'' | digit)*) as id { Ident id }



{
}
