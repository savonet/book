MD = $(wildcard *.md)
PANDOC = pandoc --bibliography=papers.bib --filter=scripts/include --syntax-definition=liquidsoap.xml

all: book.pdf language.dtd
	@$(MAKE) -C scripts

ci:
	git ci . -m "Worked on the book."
	git push

book.pdf: book.md $(MD)
	@echo "Generating $@..."
	@$(PANDOC) --top-level-division=chapter -V links-as-notes=true $< -o $@

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

check:
	$(MAKE) -C liq $@

test:
	$(MAKE) -C scripts
	pandoc --filter=scripts/inspect --filter=scripts/include test.md


%.tex %.pdf %.html: %.md
	$(PANDOC) $^ -o $@
