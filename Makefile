all:
	rubber -d book

ci:
	git ci . -m "Worked on the book."
	git push
