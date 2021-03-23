MD = $(wildcard *.md)
LIQ = $(wildcard liq/*.liq)
PANDOC = pandoc --bibliography=papers.bib --filter=scripts/include --syntax-definition=liquidsoap.xml

all: fig scripts book.pdf language.dtd

clean:
	rm -f book.pdf book.tex book.epub book.html *.aux *.idx *.ilg *.ind *.log *.out *.toc

ci:
	git ci . -m "Worked on the book."
	git push

book.tex: book.md $(MD) $(LIQ) liquidsoap.xml
	@echo "Generating $@..."
	@$(PANDOC) --template=template.latex -s --top-level-division=chapter --filter=scripts/crossref -V links-as-notes=true $< -o $@

book.pdf: book.tex
	@echo "Generating $@..."
	pdflatex $<
	makeindex book.idx

book.epub: book.md $(MD) $(LIQ) epub.css liquidsoap.xml
	@echo "Generating $@..."
	@$(PANDOC) --toc --top-level-division=chapter --css=epub.css -V links-as-notes=true $< -o $@

liquidsoap.xml:
	wget https://raw.githubusercontent.com/savonet/liquidsoap/master/scripts/liquidsoap.xml

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

fig:
	@$(MAKE) -C fig

scripts:
	@$(MAKE) -C scripts

check:
	$(MAKE) -C liq $@

test:
	$(MAKE) -C scripts
	pandoc --filter=scripts/inspect --filter=scripts/include -t LaTeX test.md

%.html: %.md $(MD) liquidsoap.xml
	$(PANDOC) -s $< -o $@

%.tex %.pdf: %.md liquidsoap.xml
	$(PANDOC) --filter=scripts/crossref -s $< -o $@

.PHONY: fig scripts
