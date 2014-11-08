all: src/lexer.cmo
	ocamlopt -o petitghc src/main.ml

src/lexer.cmo: src/parser.cmo
	cd src; ocamlopt -c lexer.ml

src/parser.cmo: src/parser.cmi
	cd src; ocamlopt -c parser.ml

src/parser.cmi: src/ast.cmo
	cd src; ocamlopt -c parser.mli

src/ast.cmo:
	ocamlopt -c src/ast.ml

src/lexer.ml: src/lexer.mll
	ocamllex src/lexer.mll

src/parser.mli src/parser.ml: src/parser.mly
	menhir -v src/parser.mly

.depend: src/lexer.ml src/parser.mli src/parser.ml
	ocamldep *.ml *.mli > .depend

include .depend
