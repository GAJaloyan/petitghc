all:
	ocamlbuild -cflags "-w -3-30",-rectypes main.native
	mv main.native petitghc

.PHONY: clean
clean:
	ocamlbuild -clean
