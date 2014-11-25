all:
	ocamlbuild -I src src/main.native -use-menhir;
	mv main.native petitghc

.PHONY: clean
clean:
	ocamlbuild -clean
