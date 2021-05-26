TEX = $(wildcard *.tex)
PDF = $(TEX:.tex=.pdf)
PNG = $(TEX:.tex=.png)

all: pdf png

pdf: $(PDF)

png: $(PNG)

clean:
	rm -f *.aux *.log $(PDF) $(PNG)

%.pdf: %.tex
	pdflatex $<

%.png: %.pdf
	@echo "Generating $@..."
	@pdftoppm -png $< > $@
