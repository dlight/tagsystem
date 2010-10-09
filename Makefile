PROJECT := test
LINK_PKG := pgocaml
COMP_PKG := pgocaml,pgocaml.syntax

.PHONY: all
.PHONY: clean

all: $(PROJECT)

clean:
	rm -f *.cm? $(PROJECT)

$(PROJECT): $(PROJECT).cmo
	ocamlfind ocamlc -package $(LINK_PKG) -linkpkg -o $@ $<

$(PROJECT).cmo: $(PROJECT).ml
	PGHOST=localhost ocamlfind ocamlc -package $(COMP_PKG) \
					-syntax camlp4o -c $<

