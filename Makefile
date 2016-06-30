## Put this Makefile in your project directory---i.e., the directory
## containing the paper you are writing. Assuming you are using the
## rest of the toolchain here, you can use it to create .html, .tex,
## and .pdf output files (complete with bibliography, if present) from
## your markdown file. 
## -	Change the paths at the top of the file as needed.
## -	Using `make` without arguments will generate html, tex, and pdf 
## 	output files from all of the files with the designated markdown
##	extension. The default is `.md` but you can change this. 
## -	You can specify an output format with `make tex`, `make pdf` or 
## - 	`make html`. 
## -	Doing `make clean` will remove all the .tex, .html, and .pdf files 
## 	in your working directory. Make sure you do not have files in these
##	formats that you want to keep!

.DEFAULT_GOAL := chapters

## Markdown extension (e.g. md, markdown, mdown).
MEXT = md

## All markdown files in the working directory
PRE_CHAPTERS = $(wildcard 00_*.$(MEXT))
CHAPTERS = $(wildcard [0-9][0-9]-*.$(MEXT))
BUILD_DIR = output

## Location of your working bibliography file
BIB = support/book.bibtex

HASKELL_BIN_PATH = ~/.cabal/bin
PANDOC_CROSSREF_PATH = $(HASKELL_BIN_PATH)/pandoc-crossref
PANDOC_CITEPROC_PREAMBLE_PATH = $(HASKELL_BIN_PATH)/pandoc-citeproc-preamble

PDFS=$(patsubst %.$(MEXT),$(BUILD_DIR)/%.pdf,$(CHAPTERS))
HTML=$(patsubst %.$(MEXT),$(BUILD_DIR)/%.html,$(CHAPTERS))
DOCX=$(patsubst %.$(MEXT),$(BUILD_DIR)/%.docx,$(CHAPTERS))
BOOKS=output/book.pdf output/book.docx

## FIGURES ##

FIGURES = 

## END FIGURES ##

ALL = $(FIGURES) $(PDFS) $(HTML) $(DOCX) $(BOOKS)

.PHONY: chapters all clean pdf html docx book webpage

chapters: $(FIGURES) $(PDFS) $(HTML) $(DOCX)

all:	$(ALL)

pdf:	$(FIGURES) $(PDFS)
html:	$(FIGURES) $(HTML)
docx:	$(FIGURES) $(DOCX)
book:   $(FIGURES) $(BOOKS)
webpage: $(FIGURES) output/book.html

PANDOC_PDF = pandoc \
	-r markdown+footnotes \
	--template=support/templates/default.latex \
	--filter $(PANDOC_CROSSREF_PATH) \
	--filter pandoc-citeproc --bibliography=$(BIB) \
	--filter $(PANDOC_CITEPROC_PREAMBLE_PATH) -M citeproc-preamble=support/templates/my_preamble.tex \
	-V geometry:"top=1in, bottom=1in, left=1.25in, right=1.25in" \
	-V class:article \
	-V fontsize:11pt \
	-V fontfamily:lmodern \
	-H support/include-in-header \
	--toc \
	--toc-depth=4 \
	--number-section \

PANDOC_DOCX = pandoc \
	-r markdown+footnotes \
	--number-section \
	--toc \
	--toc-depth=4 \
	--filter $(PANDOC_CROSSREF_PATH) \
	--reference-docx=support/template.docx \
	--filter pandoc-citeproc --bibliography=$(BIB) \

PANDOC_HTML = pandoc \
	-r markdown+footnotes+auto_identifiers+implicit_header_references \
	--template=support/html-template.html \
	--toc \
	--toc-depth=4 \
	--filter $(PANDOC_CROSSREF_PATH) \
	--filter pandoc-citeproc --bibliography=$(BIB) \
	-m \
	--number-section \
	--section-divs \

output/book.tex: support/book-metadata.yml support/shared-metadata.yml $(PRE_CHAPTERS) $(CHAPTERS)
	$(PANDOC_PDF) \
	--chapters \
	-s -S -o $@ $^

output/book.pdf: support/book-metadata.yml support/shared-metadata.yml $(PRE_CHAPTERS) $(CHAPTERS)
	$(PANDOC_PDF) \
	--chapters \
	-s -S -o $@ $^

output/book.html: support/book-metadata.yml support/shared-metadata.yml $(PRE_CHAPTERS) $(CHAPTERS)
	$(PANDOC_HTML) \
	-s -S -o $@ $^

output/book.docx: support/book-metadata.yml support/shared-metadata.yml $(PRE_CHAPTERS) $(CHAPTERS)
	$(PANDOC_DOCX) \
	-s -S -o $@ $^

$(BUILD_DIR)/%.tex: support/shared-metadata.yml %.$(MEXT)
	$(PANDOC_PDF) \
	-s -S -o $@ $^

$(BUILD_DIR)/%.pdf: support/shared-metadata.yml %.$(MEXT)
	$(PANDOC_PDF) \
	-s -S -o $@ $^

$(BUILD_DIR)/%.html: support/shared-metadata.yml %.$(MEXT)
	$(PANDOC_HTML) \
	-s -S -o $@ $^

$(BUILD_DIR)/%.docx: support/shared-metadata.yml %.$(MEXT)
	$(PANDOC_DOCX) \
	-s -S -o $@ $^

clean:
	rm -f $(BUILD_DIR)/*
