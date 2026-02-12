pdf: main.pdf

all: pdf

main.pdf: main.tex ../bibliography.bib
	pdflatex main
	bibtex main
	pdflatex main
	pdflatex main
	rm -f *.aux *.bbl *.blg *.log *.out *.toc *.lof *.lot *.fls *.fdb_latexmk

clean:
	rm -f *.aux *.bbl *.blg *.log *.out *.toc *.lof *.lot *.fls *.fdb_latexmk

distclean: clean
	rm -f main.pdf