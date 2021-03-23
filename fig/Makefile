TEX = $(wildcard *.tex)
PDF = $(TEX:.tex=.pdf)

all: $(PDF)

clean:
	rm -f *.aux *.log $(PDF)

%.pdf: %.tex
	pdflatex $<
