PACKAGES=yojson str
OCAMLOPT=ocamlfind ocamlopt -annot $(addprefix -package ,$(PACKAGES)) -linkpkg

all: pandoc.cmx inspect include crossref abbreviations

clean:
	rm -f *.annot *.cmi *.cmx *.o

test: all
	pandoc --filter=inspect --filter=crossref -t LaTeX test.md

%: pandoc.cmx %.ml
	$(OCAMLOPT) $^ -o $@

%.cmx: %.ml
	$(OCAMLOPT) -c $^
