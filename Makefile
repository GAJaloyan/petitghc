all:
	ocamlbuild -I src src/main.native -use-menhir -use-ocamlfind;
	mv main.native petitghc;

test_lexer:
	ocamlbuild -I src src/test_lexer.native -use-menhir -use-ocamlfind;
	./test_lexer.native

test_parser:
	ocamlbuild -I src src/test_parser.native -use-menhir -use-ocamlfind;
	./test_parser.native

.PHONY: clean
clean:
	ocamlbuild -clean
