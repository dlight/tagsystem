PROJECT := tagsystem

MODULES := db tagsystem

LINK_PKG := pgocaml,batteries
COMP_PKG := pgocaml,batteries,pgocaml.syntax

#--------------------------------------------------#
OPT := -I src

LINK_OPT := -package $(LINK_PKG) -linkpkg -thread
COMP_OPT := -package $(COMP_PKG) -syntax camlp4o -c

COMMAND := PGHOST=localhost ocamlfind ocamlc $(OPT)
OBJECTS := $(patsubst %,src/%.cmo, $(MODULES))

#--------------------------------------------------#
all: bin/$(PROJECT)
force: clean all
run: all
	./run
clean:
	rm -f src/*.cm? bin/$(PROJECT)
mli:
	$(COMMAND) $(COMP_OPT) -i src/*.ml

#--------------------------------------------------#
bin/$(PROJECT): $(OBJECTS)
	$(COMMAND) $(LINK_OPT) \
	$^ -o $@

src/%.cmo: src/%.ml
	$(COMMAND) $(COMP_OPT) \
	$^
	@echo