all:
	ocamlbuild -I src src/main.native -use-menhir;
	mv main.native petitghc;
	./petitghc test.hs

test_lexer:
	ocamlbuild -I src src/test_lexer.native -use-menhir;
	./test_lexer.native

test_parser:
	ocamlbuild -I src src/test_parser.native -use-menhir;
	./test_parser.native

.PHONY: clean
clean:
	ocamlbuild -clean
