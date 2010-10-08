PROJECT := test
LINK_PKG := pgocaml
COMP_PKG := pgocaml,pgocaml.syntax
all: $(PROJECT)
$(PROJECT): $(PROJECT).cmo
ocamlfind ocamlc -package $(LINK_PKG) -linkpkg -o $@ $<
$(PROJECT).cmo: $(PROJECT).ml
ocamlfind ocamlc -package $(COMP_PKG) -syntax camlp4o -c $<

