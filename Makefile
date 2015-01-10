all:
	ocamlbuild main.native
	mv main.native petitghc

.PHONY: clean
clean:
	ocamlbuild -clean
