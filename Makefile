MD = $(wildcard *.md)
LIQ = $(wildcard liq/*.liq)
PANDOC = pandoc --bibliography=papers.bib --filter=pandoc-include --filter=pandoc-replace -V today="`LC_TIME=en_US date '+%A %d, %Y'`"

all: fig book.pdf language.dtd

clean:
	rm -f book.pdf book.tex book.epub book.html *.aux *.idx *.ilg *.ind *.log *.out *.toc

ci:
	git ci . -m "Worked on the book."
	git push

book.tex: book.md style.sty $(MD) $(LIQ) liquidsoap.xml replacements
	@echo "Generating $@..."
	@$(PANDOC) -s --top-level-division=chapter --filter=pandoc-crossref -V links-as-notes=true $< -o tmp.$@
	@cat tmp.$@ \
		| sed 's/\\includegraphics\([^{]*\){\(.*\)}\\\\/\\begin{center}\\includegraphics\1{\2}\\end{center}/' \
		| sed 's/\\DeclareRobustCommand{\\href}\[2\]{#2\\footnote{\\url{#1}}}/\\DeclareRobustCommand{\\href}[2]{#2\\footnote{\\texttt{\\url{#1}}}}/' \
		> $@
	@rm -f tmp.$@

book.pdf: book.tex
	@echo "Generating $@..."
	pdflatex $<
	makeindex book.idx

web.tex: book.md style.sty $(MD) $(LIQ) liquidsoap.xml replacements Makefile
	@echo "Generating $@..."
	@$(PANDOC) -s --syntax-definition=liquidsoap.xml --top-level-division=chapter -V geometry:"" -V papersize:a4 -V geometry:"margin=4cm" -V colorlinks:true $< -o $@
web.pdf: web.tex
	@echo "Generating $@..."
	pdflatex web.tex
	makeindex web.idx
	pdflatex web.tex

book.epub book.txt: book.md $(MD) $(LIQ) epub.css liquidsoap.xml
	@echo "Generating $@..."
	@$(MAKE) -C cover --no-print-directory
	@$(PANDOC) -s --syntax-definition=liquidsoap.xml --filter=pandoc-pdf2png --toc --toc-depth=2 --top-level-division=chapter --css=epub.css --epub-cover-image cover/cover-ebook.jpg -V links-as-notes=true $< -o $@

book.html: book.md $(MD) $(LIQ) epub.css liquidsoap.xml
	@echo "Generating $@..."
	@$(PANDOC) -s --syntax-definition=liquidsoap.xml --filter=pandoc-pdf2png --top-level-division=chapter --css=epub.css -V links-as-notes=true $< -o $@
	@sed -i 's/<head>/<head><meta http-equiv="content-type" content="text\/html; charset=UTF-8"\/>/' $@

book.rst: book.md $(MD) $(LIQ) epub.css liquidsoap.xml
	@echo "Generating $@..."
	@$(PANDOC) -s --syntax-definition=liquidsoap.xml --filter=pandoc-pdf2png --top-level-division=chapter --css=epub.css -V links-as-notes=true $< -o $@

ebook.zip: fig book.html
	zip $@ book.html fig/*.png

liquidsoap.xml:
	wget https://raw.githubusercontent.com/savonet/liquidsoap/master/scripts/liquidsoap.xml

language.dtd:
	wget https://github.com/jgm/highlighting-kate/blob/master/xml/language.dtd

fig:
	@$(MAKE) -C fig

check:
	$(MAKE) -C liq $@

docker-test:
	docker build . -f .github/docker/Dockerfile.build

docker-run:
	docker run -it --entrypoint /bin/bash --user root savonet/liquidsoap:main

%.html: %.md $(MD) liquidsoap.xml
	$(PANDOC) -s $< -o $@

%.tex %.pdf: %.md liquidsoap.xml
	$(PANDOC) --filter=pandoc-crossref -s $< -o $@

site: web.pdf
	mkdir -p site/public
	cp web.pdf site/public/book.pdf
	$(MAKE) -C cover cover-ebook.svg
	cp cover/cover-ebook.svg site/public/book.svg
	$(MAKE) -C site

.PHONY: fig scripts site
