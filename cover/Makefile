all: cover.pdf cover-ebook.jpg cover-ebook.svg

clean:
	rm -f *.aux *.log cover.pdf cover-ebook.jpg cover-ebook.svg

cover.pdf: abstract

cover-ebook.jpg: cover-ebook.pdf
	@echo "Generating $@..."
	@pdftoppm -jpeg -jpegopt quality=100,optimize=y -scale-to 2560 $< > $@

%.pdf: %.tex
	pdflatex $<

%.svg: %.pdf
	@echo "Generating $@..."
	@pdf2svg $< $@
