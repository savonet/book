MD = $(addprefix md/,$(addsuffix .md,$(shell cat plan)))
PANDOC = pandoc --bibliography=papers.bib --filter=scripts/include --syntax-definition=liquidsoap.xml

all: book.md language.dtd
	@$(MAKE) -C scripts
	@echo "Generating pdf..."
	@$(PANDOC) --top-level-division=chapter book.md -o book.pdf

ci:
	git ci . -m "Worked on the book."
	git push

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

%.pdf %.html: %.md
	$(PANDOC) $^ -o $@
