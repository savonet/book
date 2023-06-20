all: index.html
	mkdir -p public
	cp *.html *.css public/

%.html: %.md
	pandoc -s $< --css pandoc.css -o $@

.PHONY: all
