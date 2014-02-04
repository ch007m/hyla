#!/bin/sh

echo "Create Project"
rm -rf ~hyla/MyBlankProject
hyla new -b -d ~/hyla/MyBlankProject --force

echo "Generate HTML Content of MyBlank project"
cd ~/hyla/MyBlankProject

echo "Backup _config.yaml file as we don't use it here"
mv _config.yaml _config.yaml.bk

echo "Add asciidoc files"
hyla new -b -d MyBlankProject --force
hyla create --t asciidoc --a article --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a book --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a image --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a audio --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a video --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a source --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a table --d ~/hyla/MyBlankProject

hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content

echo "Revert _config.yaml file"
mv _config.yaml.bk _config.yaml