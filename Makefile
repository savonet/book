MD = $(addprefix md/,$(addsuffix .md,$(shell cat plan)))

all: book.md
	pandoc book.md --top-level-division=chapter -o book.pdf

ci:
	git ci . -m "Worked on the book."
	git push

book.md: $(MD)
	cat $(MD) > $@

