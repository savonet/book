MD = $(addprefix md/,$(addsuffix .md,$(shell cat plan)))

all: book.md
	pandoc book.md --top-level-division=chapter -o book.pdf

book.md: $(MD)
	cat $(MD) > $@

