#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyBlankProject and add artefacts"
cd ~/hyla

echo "Create a new Blank project"
hyla new -b MyBlankProject --force

echo "Add asciidoc files using artefacts and template"
hyla add --t asciidoc --a article --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a book --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a image --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a audio --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a video --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a source --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a table --d ~/hyla/MyBlankProject

echo "Project created"
ls -la ~/hyla/MyBlankProject


