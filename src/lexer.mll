{
    exception LexingError

    open Parser
    open Lexing

    let char_of_car s =
        if String.length s = 1 then s.[0]
        else match s.[1] with
        | 'n'  -> '\n'
        | 't'  -> '\t'
        | '"'  -> '"'
        | '\\' -> '\\'
        | _    -> raise LexingError

    let newline lexbuf =
        let pos = lexbuf.lex_curr_p in
        lexbuf.lex_curr_p <-
            { pos with pos_lnum = pos.pos_lnum + 1; pos_bol = pos.pos_cnum }

    let firstCol = ref true
}

let digit = ['0'-'9']
let car   = ['\032'-'\033' '\035'-'\091' '\093'-'\126'] | "\\\\" | "\\\"" | "\\n" | "\\t"
let empty = ['\n' '\t' ' ']
let lower = ['a'-'z']
let alpha = ['a'-'z' 'A'-'Z']

rule lexer = parse
| '\n'                  { firstCol := true; newline lexbuf; lexer lexbuf }
| empty+                { lexer lexbuf }
| eof                   { Eof }
| "--" [^'\n']* '\n'?   { firstCol := false; lexer lexbuf }
| "if"                  { firstCol := false; If }
| "then"                { firstCol := false; Then }
| "else"                { firstCol := false; Else }
| "="                   { firstCol := false; Assign }
| "{"                   { firstCol := false; LeftCurly }
| "}"                   { firstCol := false; RightCurly }
| "["                   { firstCol := false; LeftBracket }
| "]"                   { firstCol := false; RightBracket }
| "("                   { firstCol := false; LeftPar }
| ")"                   { firstCol := false; RightPar }
| "+"                   { firstCol := false; Plus }
| "-"                   { firstCol := false; Minus }
| "*"                   { firstCol := false; Time }
| ">"                   { firstCol := false; Greater }
| ">="                  { firstCol := false; GreaterEq }
| "<"                   { firstCol := false; Lower }
| "<="                  { firstCol := false; LowerEq }
| "/="                  { firstCol := false; Unequal }
| "=="                  { firstCol := false; Equal }
| "&&"                  { firstCol := false; And }
| "||"                  { firstCol := false; Or }
| ":"                   { firstCol := false; Colon }
| "return"              { firstCol := false; Return }
| "do"                  { firstCol := false; Do }
| "case"                { firstCol := false; Case }
| "of"                  { firstCol := false; Of }
| "True"                { firstCol := false; True }
| "False"               { firstCol := false; False }
| ","                   { firstCol := false; Comma }
| "\\"                  { firstCol := false; Lambda }
| "->"                  { firstCol := false; Arrow }
| ";"                   { firstCol := false; Semicolon }
| "let"                 { firstCol := false; Let }
| "in"                  { firstCol := false; In }
| digit+ as inum        { firstCol := false; Int (int_of_string inum) }
| '\'' (car as c) '\''  { firstCol := false; Char (char_of_car c) }
| '"' (car* as str) '"' { firstCol := false; String str }
| (lower (alpha | '_' | '\'' | digit)*) as id { if !firstCol then (firstCol := false; Ident0 id) else Ident id }
| _                     { raise LexingError }
