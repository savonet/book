PACKAGES=yojson str
OCAMLOPT=ocamlfind ocamlopt -annot $(addprefix -package ,$(PACKAGES)) -linkpkg

all: pandoc.cmx inspect include crossref

clean:
	rm -f *.annot *.cmi *.cmx *.o

%: pandoc.cmx %.ml
	$(OCAMLOPT) $^ -o $@

%.cmx: %.ml
	$(OCAMLOPT) -c $^
