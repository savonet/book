TEX = $(wildcard *.tex)
PDF = $(TEX:.tex=.pdf)
PNG = $(TEX:.tex=.png)

all: $(PDF)

png: $(PNG)

clean:
	rm -f *.aux *.log $(PDF) $(PNG)

%.pdf: %.tex
	pdflatex $<

%.png: %.pdf
	# convert -density 150 $< $@
	pdftoppm -png $< > $@
