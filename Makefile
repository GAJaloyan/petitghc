all:
	ocamlbuild main.native | grep -v -i 'is defined in both types'
	mv main.native petitghc

.PHONY: clean
clean:
	ocamlbuild -clean
