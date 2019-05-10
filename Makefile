MD = $(addprefix md/,$(addsuffix .md,$(shell cat plan)))

all: book.md language.dtd
	pandoc book.md --top-level-division=chapter --syntax-definition=liquidsoap.xml -o book.pdf

ci:
	git ci . -m "Worked on the book."
	git push

book.md: $(MD)
	cat $(MD) > $@


language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd
