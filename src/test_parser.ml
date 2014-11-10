#use "parser.ml";;
#use "lexer.ml";;

let test tfile = file lexer (Lexing.from_channel (open_in tfile))
