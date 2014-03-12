#!/bin/sh

echo "Generate HTML Content of MyBlank project - Style Foundation"

echo "Create Project"
rm -rf ~hyla/MyBlankProject
hyla new -b -d ~/hyla/MyBlankProject --force

cd ~/hyla/MyBlankProject

echo "Add asciidoc files"
hyla new -b -d MyBlankProject --force
hyla add --t asciidoc --a article --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a book --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a image --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a audio --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a video --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a source --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a table --d ~/hyla/MyBlankProject

echo "Change style in the _config.yaml file"
ruby -i.bak -pe 'sub(%r{style: liberation},"style: foundation")' _config.yaml

#hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content --style liberation
#hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content --style github
hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content -y foundation

echo "Revert _config.yaml file"
mv _config.yaml.bk _config.yaml
