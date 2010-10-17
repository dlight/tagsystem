#--------------------------------------------------#
PROJECT := tagsystem

MODULES := db tagsystem
PKG     := pgocaml,batteries,pgocaml.syntax

#--------------------------------------------------#
OPT := -I src -package $(PKG) -syntax camlp4o

COMP_OPT := $(OPT) -c
LINK_OPT := $(OPT) -linkpkg -thread
DOC_OPT  := $(OPT) -stars -sort

COMMAND := ocamlfind ocamlc
DOC     := ocamlfind ocamldoc $(DOC_OPT)

BIN     := bin/$(PROJECT)
OBJECTS := $(patsubst %,src/%.cmo, $(MODULES))
SOURCES := $(patsubst %,src/%.ml, $(MODULES))

#--------------------------------------------------#
$(PROJECT):  $(BIN)

all:         $(PROJECT) doc
doc:         html tex pdf
force:       clean $(PROJECT)

run: $(PROJECT)
	./run

clean:
	rm -f $(BIN) src/*.cm? html/* tex/*
mli:
	$(COMMAND) $(COMP_OPT) -i src/*.ml

#--------------------------------------------------#
html: $(BIN)
	@mkdir -p html
	$(DOC) -html -d html \
	$(SOURCES)

tex: $(BIN)
	@mkdir -p tex
	$(DOC) -latex -o tex/tagsystem.tex \
	$(SOURCES)

pdf: tex
	cd tex; pdflatex tagsystem.tex

$(BIN): $(OBJECTS)
	@mkdir -p bin
	$(COMMAND) $(LINK_OPT) \
	$^ -o $@

src/%.cmo: src/%.ml $(shell echo $(SOURCES) | sed 's:$(^).*::' | tee /tmp/a)
	$(COMMAND) $(COMP_OPT) \
	$^
	@echo

destroy: $(OBJECTS)
	@if [ `whoami` = dev ]; then \
		make really-destroy; \
	else \
		echo VCVCVC ESTA LOUCO AAAAAAAA; \
	fi

really-destroy: src/createdb.cmo $(OBJECTS)
	@mkdir -p dump
	pg_dump > dump/`date "+%Y-%m-%d.%H-%m-%S"`
	$(COMMAND) $(LINK_OPT) \
	$^ -o $(BIN)
