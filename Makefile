MD = $(wildcard *.md)
LIQ = $(wildcard liq/*.liq)
PANDOC = pandoc --bibliography=papers.bib --filter=scripts/include --syntax-definition=liquidsoap.xml

all: scripts book.pdf language.dtd

ci:
	git ci . -m "Worked on the book."
	git push

book.pdf: book.md $(MD) $(LIQ)
	@echo "Generating $@..."
	@$(PANDOC) --top-level-division=chapter --filter=scripts/crossref -V links-as-notes=true $< -o $@

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

scripts:
	@$(MAKE) -C scripts

check:
	$(MAKE) -C liq $@

test:
	$(MAKE) -C scripts
	pandoc --filter=scripts/inspect --filter=scripts/include --filter=scripts/crossref -t LaTeX test.md

%.tex %.pdf %.html: %.md
	$(PANDOC) $^ -o $@

.PHONY: scripts
