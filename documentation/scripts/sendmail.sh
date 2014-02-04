#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyEmailProject"
hyla new -b -d ~/hyla/MyEmailProject --force

cd ~/hyla/MyEmailProject

echo "Add an artefact - asciidoc with images"
hyla create --a image --d ~/hyla/MyEmailProject

echo "Generate HTML content"
hyla generate -r adoc2html -s ~/hyla/MyEmailProject/ -d ~/hyla/MyEmailProject/generated_content

# ?? Find a way to add SMTP Server, user, password ??
echo "Send email"
#hyla sendmail

