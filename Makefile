PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
DATADIR ?= $(PREFIX)/share/ocaml-todo-cli

PKGS=-package sqlite3 -package unix
NAME=todo
DEBUG_OBJS=setup.cmo repo.cmo main.cmo
OBJS=setup.cmx repo.cmx main.cmx

OPAM=opam exec --
OCAMLFIND=$(OPAM) ocamlfind
OCAMLC=$(OCAMLFIND) ocamlc
OCAMLOPT=$(OCAMLFIND) ocamlopt
OCAMLFLAGS=$(PKGS) -linkpkg
OCAMLOPTFLAGS=-O3 $(PKGS) -linkpkg

.PHONY: debug
debug: $(DEBUG_OBJS)
	$(OCAMLC) -o $(NAME) $(OCAMLFLAGS) $(DEBUG_OBJS)

.PHONY: release
release: $(OBJS)
	$(OCAMLOPT) -o $(NAME) $(OCAMLOPTFLAGS) $(OBJS)

.PHONY: install
install: release
	install -d $(BINDIR)
	install -m 755 $(NAME) $(BINDIR)/$(NAME)
	mkdir -p $(DATADIR)

.PHONY: uninstall
uninstall:
	rm -f $(BINDIR)/$(NAME)

.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) \
	-pp "sed 's|@DATADIR@|'$(DATADIR)'|g'" \
	-c $<

.ml.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) \
	-pp "sed 's|@DATADIR@|'$(DATADIR)'|g'" \
	-c $<

.PHONY: clean
clean:
	$(RM) $(NAME) *.o *.cmx *.cmi *.cmo generated.*

