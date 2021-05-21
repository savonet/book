MD = $(wildcard *.md)
LIQ = $(wildcard liq/*.liq)
PANDOC = pandoc --bibliography=papers.bib --filter=pandoc-include --filter=pandoc-replace

all: fig book.pdf language.dtd

clean:
	rm -f book.pdf book.tex book.epub book.html *.aux *.idx *.ilg *.ind *.log *.out *.toc

ci:
	git ci . -m "Worked on the book."
	git push

book.tex: book.md style.sty $(MD) $(LIQ) liquidsoap.xml replacements
	@echo "Generating $@..."
	@$(PANDOC) --template=template.latex -s --syntax-definition=liquidsoap.xml --top-level-division=chapter --filter=pandoc-crossref -V links-as-notes=true $< -o tmp.$@
	@cat tmp.$@ \
		| sed 's/\\includegraphics\([^{]*\){\(.*\)}\\\\/\\begin{center}\\includegraphics\1{\2}\\end{center}/' \
		| sed 's/\\DeclareRobustCommand{\\href}\[2\]{#2\\footnote{\\url{#1}}}/\\DeclareRobustCommand{\\href}[2]{#2\\footnote{\\texttt{\\url{#1}}}}/' \
		> $@
	@rm -f tmp.$@

book.pdf: book.tex
	@echo "Generating $@..."
	pdflatex $<
	makeindex book.idx

web.tex: book.md style.sty $(MD) $(LIQ) liquidsoap.xml replacements Makefile
	@echo "Generating $@..."
	@$(PANDOC) -s --syntax-definition=liquidsoap.xml --top-level-division=chapter -V geometry:"" -V papersize:a4 -V geometry:"margin=4cm" -V colorlinks:true $< -o $@
web.pdf: web.tex
	@echo "Generating $@..."
	pdflatex web.tex
	makeindex web.idx

book.epub book.html: book.md $(MD) $(LIQ) epub.css liquidsoap.xml
	@$(MAKE) -C fig png
	@echo "Generating $@..."
	@$(PANDOC) -s --syntax-definition=liquidsoap.xml --filter=pandoc-pdf2png --toc --top-level-division=chapter --css=epub.css -V links-as-notes=true $< -o $@

liquidsoap.xml:
	wget https://raw.githubusercontent.com/savonet/liquidsoap/master/scripts/liquidsoap.xml

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

fig:
	@$(MAKE) -C fig

check:
	$(MAKE) -C liq $@

docker-test:
	docker build . -f .github/docker/Dockerfile.build

docker-run:
	docker run -it --entrypoint /bin/bash --user root savonet/liquidsoap:main

%.html: %.md $(MD) liquidsoap.xml
	$(PANDOC) -s $< -o $@

%.tex %.pdf: %.md liquidsoap.xml
	$(PANDOC) --filter=pandoc-crossref -s $< -o $@

.PHONY: fig scripts
