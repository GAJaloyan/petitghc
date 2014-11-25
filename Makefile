all:
	ocamlbuild -I src src/main.native -use-menhir;
	mv main.native petitghc

test_parser:
	ocamlbuild -I src src/test_parser.native -use-menhir;
	./test_parser.native

.PHONY: clean
clean:
	ocamlbuild -clean
