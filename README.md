# Contents of repo

1. `Makefile` - provides rules for generating PDF, HTML, and .docx versions of a book from Markdown files using pandoc.
2. `scripts/split-sections.rb` - Splits up single HTML file from pandoc into separate HTML files, one per section. Usage: `./scripts/split-sections.rb output/book.html directory/to/place/html/section/files/ > output/data.json`. The JSON data that this command spits out is meta-data about the book that is useful for determining which section is next or generating a table of contents.
