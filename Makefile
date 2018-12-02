all:
	rubber -W refs -d book

clean:
	rubber --clean book

ci:
	git ci . -m "Worked on the book."
	git push
