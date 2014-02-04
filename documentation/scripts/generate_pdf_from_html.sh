#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyPdfProject"
cd ~/hyla
hyla new --blank -d MyPdfProject --force
cd MyPdfProject

echo "Create one Asciidoc file from sample (book)"

hyla create -a book --t asciidoc -d .

echo "Generate HTML content using foundation stylesheet"

hyla generate --style foundation

echo "We change the rendering from adoc2html to html2pdf"

ruby -i.bak -pe 'sub(%r{rendering: adoc2html},"rendering: html2pdf")' _config.yaml

echo "Adapt source directory & destination directory"

ruby -i.bak -pe 'sub(%r{source: .},"source: ./generated_content")' _config.yaml
ruby -i.bak -pe 'sub(%r{destination: generated_content},"destination: ./generated_content/pdf")' _config.yaml

echo "Generate the PDF file for the image and book"

hyla generate -f asciidoc_book.html
hyla generate -f asciidoc_image.html

echo "Result can be opened and viewed"

open generated_content/pdf/asciidoc_book.pdf
open generated_content/pdf/asciidoc_image.pdf

