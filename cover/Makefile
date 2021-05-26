all: cover.pdf cover-ebook.jpg

cover.pdf: abstract

cover-ebook.jpg: cover-ebook.pdf
	# convert -density 214 -scale 1600x2560 $< $@
	pdftoppm -jpeg -scale-to 2560 $< > $@

%.pdf: %.tex
	pdflatex $<
