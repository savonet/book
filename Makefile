MD = $(addprefix md/,$(addsuffix .md,$(shell cat plan)))

all: book.md language.dtd
	@$(MAKE) -C scripts
	pandoc book.md --filter=scripts/include --top-level-division=chapter --syntax-definition=liquidsoap.xml -o book.pdf

ci:
	git ci . -m "Worked on the book."
	git push

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

%.pdf %.html: %.md
	pandoc $^ --filter=scripts/include -o $@
