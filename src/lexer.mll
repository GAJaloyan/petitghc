{

  open Lexing
  open Format
  open Parser
  exception Lexing_error of string
let kwd_tbl =
[
  "else", ELSE;
  "if", IF;
  "in", IN;
  "let", LET;
  "case", CASE;
  "of", OF;
  "then", THEN;
  "return", RETURN;
  "do", DO;
  
]

let identnum = ref 0
	

let id_or_kwd s = try List.assoc s kwd_tbl with _ -> begin (if(!identnum = 0) then IDENT0 s else IDENT1 s ) end
  
  let newline lexbuf =
    let pos = lexbuf.lex_curr_p in begin 
    lexbuf.lex_curr_p <-
      { pos with pos_lnum = pos.pos_lnum + 1; pos_bol = pos.pos_cnum } end
}


let chiffre = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let ident = ['a'-'z'] (alpha | '_' | '\'' | chiffre)*

let entier = ['0'-'9']+
let car = [' '-'!' '#'-'[' ']'-'~'] | "\\\\" | "\\\"" | "\\n" | "\\t"
let carno = [' '-'!' '#'-'[' ']'-'~']
let caractere = '\'' car '\''
let chaine = '\"' (car)* '\"'

rule token = parse
	|'\n'
      { identnum := 0; new_line lexbuf; token lexbuf }
  | [' ' '\t']+
      { identnum := 1;  token lexbuf }
  | "--"  [^'\n']* ('\n'|eof) { identnum := 0; new_line lexbuf; token lexbuf }
  
  | ident as id {let s = id_or_kwd id in begin identnum := 1; s end}
  | entier as integ {identnum := 1; INTEGER  (int_of_string integ)}
  | "True" {identnum := 1; VTRUE}
  | "False" {identnum := 1; VFALSE}
  | '\'' {identnum:=1; read_carac lexbuf}
  | '"' {identnum:=1; let s = read_string lexbuf in VSTRING (s)}
  
  | ';' {identnum := 1; try read_pv lexbuf with _ -> SEMICOLON}
  
  | "{" {identnum := 1; LCBR}
  | "}" {identnum := 1; RCBR}
  | "->" {identnum := 1;FLECHE}
  | '[' {identnum := 1;LBRA}
  | ']' {identnum := 1;RBRA}
  | '(' {identnum := 1;LPAR}
  | ')' {identnum := 1;RPAR}
  | '=' {identnum := 1;EGAL}
  | '\\' {identnum := 1;BACKSLASH}
  | '+' {identnum := 1; PLUS}
  | '-' {identnum := 1; MOINS}
  | '*' {identnum := 1; MULT}
  | "<=" {identnum := 1; SmallerEqual}
  | ">=" {identnum := 1; GreaterEqual}
  | "/=" {identnum := 1; NotEqual}
  | ">" {identnum := 1; Greater}
  | "<" {identnum := 1; Smaller}
  | ',' {identnum := 1; COMMA}
  | ':' {identnum := 1; COLON}
  | "&&" {identnum := 1; ETET}
  | "||" {identnum := 1; OUOU}
  | eof {EOF}
  | _ { raise (Lexing_error "Pattern not found") }
and read_pv = parse
  | "--"  [^'\n']* ('\n') { new_line lexbuf; read_pv lexbuf}
  |'\n'
      { identnum := 1; new_line lexbuf; read_pv lexbuf }
  | [' ' '\t']+
      { identnum := 1; read_pv lexbuf }
  | '}' {PVACC}

and read_carac = parse
  |carno as c {read_endcarac lexbuf; VCHAR (c)}  
  | "\\t" {read_endcarac lexbuf; VCHAR ('\t')}
  | "\\\\" {read_endcarac lexbuf; VCHAR ('\\')}
  | "\\\"" {read_endcarac lexbuf; VCHAR ('\"')}
  | "\\n" {read_endcarac lexbuf; VCHAR ('\n')}
  |eof {raise (Lexing_error "Caractere ouvert non fermé") }
  | _ {raise (Lexing_error "Caractere illégal") }

and read_endcarac = parse
	|'\'' {}
	|_ {raise (Lexing_error "Caractere ouvert mais non fermé") }
	
and read_string = parse
  |'"' {[]}
  |carno as c {c::(read_string lexbuf)}
  |"\\t" {'\t'::(read_string lexbuf)}
  |"\\\\" {'\\'::(read_string lexbuf)}
  |"\\\"" {'\"'::(read_string lexbuf)}
  |"\\n" {'\n'::(read_string lexbuf)}
  | eof {raise (Lexing_error "Chaine ouverte mais non fermée") }
  | _ {raise (Lexing_error "Caractere illégal dans la chaine") }
  

