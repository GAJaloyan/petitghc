{
    exception LexingError

    open Parser

    module E = Error 

    let char_of_car s =
        if String.length s = 1 then s.[0]
        else match s.[1] with
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
| '\n'                  { firstCol := true; (*Printf.printf "\n"; flush stdout;*) newline lexbuf; lexer lexbuf }
| empty+ as c           { firstCol := false; (*Printf.printf "%s" c; flush stdout;*) lexer lexbuf }
| eof                   { (*Printf.printf "eof"; flush stdout;*) Eof }
| "--" [^'\n']* '\n'? as s { (*Printf.printf "%s" s; flush stdout;*) firstCol := false; lexer lexbuf }
| "if"                  { (*Printf.printf "if"; flush stdout;*) firstCol := false; If }
| "then"                { (*Printf.printf "then"; flush stdout;*) firstCol := false; Then }
| "else"                { (*Printf.printf "else"; flush stdout;*) firstCol := false; Else }
| "{"                   { (*Printf.printf "{"; flush stdout;*) firstCol := false; LeftCurly }
| "}"                   { (*Printf.printf "}"; flush stdout;*) firstCol := false; RightCurly }
| "["                   { (*Printf.printf "["; flush stdout;*) firstCol := false; LeftBracket }
| "]"                   { (*Printf.printf "]"; flush stdout;*) firstCol := false; RightBracket }
| "("                   { (*Printf.printf "("; flush stdout;*) firstCol := false; LeftPar }
| ")"                   { (*Printf.printf ")"; flush stdout;*) firstCol := false; RightPar }
| "+"                   { (*Printf.printf "+"; flush stdout;*) firstCol := false; Plus }
| "-"                   { (*Printf.printf "-"; flush stdout;*) firstCol := false; Minus }
| "*"                   { (*Printf.printf "*"; flush stdout;*) firstCol := false; Time }
| ">"                   { (*Printf.printf ">"; flush stdout;*) firstCol := false; Greater }
| ">="                  { (*Printf.printf ">="; flush stdout; *)firstCol := false; GreaterEq }
| "<"                   { (*Printf.printf "<"; flush stdout;*) firstCol := false; Lower }
| "<="                  { (*Printf.printf "<="; flush stdout;*) firstCol := false; LowerEq }
| "/="                  { (*Printf.printf "/="; flush stdout;*) firstCol := false; Unequal }
| "=="                  { (*Printf.printf "=="; flush stdout;*) firstCol := false; Equal }
| "&&"                  { (*Printf.printf "&&"; flush stdout;*) firstCol := false; And }
| "||"                  { (*Printf.printf "||"; flush stdout;*) firstCol := false; Or }
| ":"                   { (*Printf.printf ":"; flush stdout;*) firstCol := false; Colon }
| "="                   { (*Printf.printf "="; flush stdout;*) firstCol := false; Assign }
| "return"              { (*Printf.printf "return"; flush stdout;*) firstCol := false; Return }
| "do"                  { (*Printf.printf "do"; flush stdout;*) firstCol := false; Do }
| "case"                { (*Printf.printf "case"; flush stdout;*) firstCol := false; Case }
| "of"                  { (*Printf.printf "of";  flush stdout;*)firstCol := false; Of }
| "True"                { (*Printf.printf "True"; flush stdout;*) firstCol := false; True }
| "False"               { (*Printf.printf "False"; flush stdout;*) firstCol := false; False }
| ","                   { (*Printf.printf ","; flush stdout;*) firstCol := false; Comma }
| "\\"                  { (*Printf.printf "\\"; flush stdout;*) firstCol := false; Lambda }
| "->"                  { (*Printf.printf "->"; flush stdout;*) firstCol := false; Arrow }
| ";"                   { (*Printf.printf ";"; flush stdout;*) firstCol := false; Semicolon }
| "let"                 { (*Printf.printf "let"; flush stdout;*) firstCol := false; Let }
| "in"                  { (*Printf.printf "in"; flush stdout;*) firstCol := false; In }
| digit+ as inum        { (*Printf.printf "%s\n" inum; flush stdout;*) firstCol := false; Int (int_of_string inum) }
| '\'' (carEsc as c) '\''  { (*Printf.printf "'%s'" c; flush stdout;*) firstCol := false; Char (char_of_car c) }
| '"'                   { (*Printf.printf "\""; flush stdout;*) firstCol := false;
                          read_string (Buffer.create 17) lexbuf }
| (lower (alpha | '_' | '\'' | digit)*) as id 
                        { (*Printf.printf "%s" id; flush stdout;*)
                          if !firstCol
                          then begin
                              firstCol := false;
                              Ident0 id
                          end
                          else Ident id }
| _                     { raise LexingError }

and read_string buf = parse
| '"' { (*Printf.printf "\""; flush stdout;*) String (Buffer.contents buf) }
| '\\' '\\' { (*Printf.printf "\\\\"; flush stdout;*) Buffer.add_char buf '\\'; read_string buf lexbuf }
| '\\' 'n' { (*Printf.printf "\\n"; flush stdout;*) Buffer.add_char buf '\n'; read_string buf lexbuf }
| '\\' 't' { (*Printf.printf "\\t"; flush stdout;*) Buffer.add_char buf '\t'; read_string buf lexbuf }
| '\\' '"' { (*Printf.printf "\\\""; flush stdout;*) Buffer.add_char buf '"'; read_string buf lexbuf }
| car as c { (*Printf.printf "%c\n" c; flush stdout;*) Buffer.add_string buf (Lexing.lexeme lexbuf); read_string buf lexbuf }
| eof { raise (E.SyntaxError "String is not terminated") }
| _ as c { (*Printf.printf "%c" c; flush stdout;*) raise (E.SyntaxError "Illegal character in string") }
