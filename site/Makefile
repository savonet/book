all: index.html
	mkdir -p public
	cp $< public/

%.html: %.md
	pandoc -s $< -o $@
