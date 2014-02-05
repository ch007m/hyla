#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyBlankProject and add artefacts"
cd ~/hyla

echo "Create a new Blank project"
hyla new -b -d MyBlankProject --force

echo "Add asciidoc files using artefacts and template"
hyla create --t asciidoc --a article --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a book --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a image --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a audio --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a video --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a source --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a table --d ~/hyla/MyBlankProject

echo "Project created"
ls -la ~/hyla/MyBlankProject


