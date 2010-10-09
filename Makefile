PROJECT := tagsystem

LINK_PKG := pgocaml,batteries
COMP_PKG := pgocaml,batteries,pgocaml.syntax

H := PGHOST=localhost

COMMAND := $(H) ocamlfind ocamlc -package

OBJECTS := $(patsubst %.ml,%.cmo,$(wildcard src/*.ml))

.PHONY: all
.PHONY: clean
.PHONE: mli

all: bin/$(PROJECT)

clean:
	rm -f src/*.cm? bin/$(PROJECT)

mli:
	$(COMMAND) $(COMP_PKG) -i -syntax camlp4o *.ml

bin/$(PROJECT): $(OBJECTS)
	$(COMMAND) $(LINK_PKG) -linkpkg -thread -o $@ $^

src/%.cmo: src/%.ml
	$(COMMAND) $(COMP_PKG) -syntax camlp4o -I src -c $^

