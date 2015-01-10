all:
	ocamlbuild main.native | grep -v -i 'is defined in both types' | grep -v -i 'File' | cat
	mv main.native petitghc

.PHONY: clean
clean:
	ocamlbuild -clean
