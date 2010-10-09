PROJECT := tagsystem

MODULES := db tagsystem

PKG := pgocaml,batteries,pgocaml.syntax

#--------------------------------------------------#
OPT := -I src -package $(PKG) -syntax camlp4o

COMP_OPT := $(OPT) -c
LINK_OPT := $(OPT) -linkpkg -thread

DOC_OPT := $(OPT) -html -stars -sort

COMMAND := PGHOST=localhost ocamlfind ocamlc $(OPT)
OBJECTS := $(patsubst %,src/%.cmo, $(MODULES))
SOURCES := $(patsubst %,src/%.ml, $(MODULES))

#--------------------------------------------------#
all: $(PROJECT) doc

force: clean all
run: all
	./run
clean:
	rm -f html/* src/*.cm? bin/$(PROJECT)
mli:
	$(COMMAND) $(COMP_OPT) -i src/*.ml

doc: $(PROJECT)
	@mkdir -p html
	ocamlfind ocamldoc $(DOC_OPT) -d html $(SOURCES) 

$(PROJECT) : bin/$(PROJECT)

#--------------------------------------------------#
bin/$(PROJECT): $(OBJECTS)
	@mkdir -p bin
	$(COMMAND) $(LINK_OPT) \
	$^ -o $@

src/%.cmo: src/%.ml
	$(COMMAND) $(COMP_OPT) \
	$^
	@echo