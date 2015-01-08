{
    exception LexingError

    open Parser

    module E = Error 

    let char_of_car s =
        if String.length s = 1 then s.[0]
        else match s.[0] with
        | 'n'  -> '\n'
        | 't'  -> '\t'
        | '"'  -> '"'
        | '\\' -> '\\'
        | _    -> raise LexingError

    let newline lexbuf =
        let pos = lexbuf.Lexing.lex_curr_p in
        lexbuf.Lexing.lex_curr_p <-
            { pos with Lexing.pos_lnum = pos.Lexing.pos_lnum + 1; Lexing.pos_bol = pos.Lexing.pos_cnum }

    let firstCol = ref true
}

let digit = ['0'-'9']
let car   = ['\032'-'\033' '\035'-'\091' '\093'-'\126'] 
let carEsc = car | "\\\\" | "\\\"" | "\\n" | "\\t"
let empty = ['\t' ' ']
let lower = ['a'-'z']
let alpha = ['a'-'z' 'A'-'Z']

rule lexer = parse
| '\n'                  { firstCol := true; newline lexbuf; lexer lexbuf }
| empty+ as c           { firstCol := false; lexer lexbuf }
| eof                   { Eof }
| "--" [^'\n']* '\n'?   { firstCol := true; lexer lexbuf }
| "if"                  { firstCol := false; If }
| "then"                { firstCol := false; Then }
| "else"                { firstCol := false; Else }
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
| "="                   { firstCol := false; Assign }
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
| '\'' (carEsc as c) '\''  { firstCol := false; Char (char_of_car c) }
| '"'                   { firstCol := false;
                          read_string (Buffer.create 17) lexbuf }
| (lower (alpha | '_' | '\'' | digit)*) as id 
                        { 
                          if !firstCol
                          then begin
                              firstCol := false;
                              Ident0 id
                          end
                          else Ident id }
| _                     { raise LexingError }

and read_string buf = parse
| '"'       { String (Buffer.contents buf) }
| '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
| '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
| '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
| '\\' '"'  { Buffer.add_char buf '"'; read_string buf lexbuf }
| car as c  { Buffer.add_string buf (Lexing.lexeme lexbuf); read_string buf lexbuf }
| eof       { raise (E.SyntaxError "String is not terminated") }
| _ as c    { raise (E.SyntaxError "Illegal character in string") }
