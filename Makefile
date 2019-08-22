MD = $(wildcard *.md)
LIQ = $(wildcard liq/*.liq)
PANDOC = pandoc --bibliography=papers.bib --filter=scripts/include --syntax-definition=liquidsoap.xml

all: scripts book.pdf language.dtd

ci:
	git ci . -m "Worked on the book."
	git push

book.tex: book.md $(MD) $(LIQ)
	@echo "Generating $@..."
	@$(PANDOC) -s --top-level-division=chapter --filter=scripts/crossref -V links-as-notes=true $< -o $@
	@chmod -w $@

book.pdf: book.tex
	@echo "Generating $@..."
	pdflatex $<
	makeindex book.idx

book.epub: book.md $(MD) $(LIQ) epub.css
	@echo "Generating $@..."
	@$(PANDOC) --toc --top-level-division=chapter --css=epub.css -V links-as-notes=true $< -o $@

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

scripts:
	@$(MAKE) -C scripts

check:
	$(MAKE) -C liq $@

test:
	$(MAKE) -C scripts
	pandoc --filter=scripts/inspect --filter=scripts/include --filter=scripts/crossref -t LaTeX test.md

%.html: %.md $(MD)
	$(PANDOC) -s $< -o $@

%.tex %.pdf: %.md
	$(PANDOC) --filter=scripts/crossref -s $< -o $@

.PHONY: scripts
