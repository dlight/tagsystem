PROJECT := test
LINK_PKG := pgocaml,batteries
COMP_PKG := pgocaml,batteries,pgocaml.syntax

COMMAND := PGHOST=localhost ocamlfind ocamlc

.PHONY: all
.PHONY: clean

all: $(PROJECT)

clean:
	rm -f *.cm? $(PROJECT)

mli:
	$(COMMAND) -i -package $(COMP_PKG) -syntax camlp4o -c test.ml

$(PROJECT): db.cmo test.cmo
	$(COMMAND) -package $(LINK_PKG) -linkpkg -thread -o $@ $^

%.cmo: %.ml
	$(COMMAND) -package $(COMP_PKG) -syntax camlp4o -c $^

