#!/bin/sh

source remove_temp_directories.sh

echo "Create a MyBlankProject and add artefacts"
cd ~/hyla

hyla new -b -d MyBlankProject --force
hyla create --t asciidoc --a article --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a book --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a image --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a audio --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a video --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a source --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a table --d ~/hyla/MyBlankProject

echo "Project created"
ls -la ~/hyla/MyBlankProject


