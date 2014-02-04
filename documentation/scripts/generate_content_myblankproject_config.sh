#!/bin/sh

echo "Generate HTML Content of MyBlank project"
echo "Styles availables : liberation, asciidoctor, colony, foundation, foundation-lime, foundation-potion, github, golo, iconic, maker, readthedocs, riak, rocket-panda, rubygems"

echo "Create Project"
rm -rf ~hyla/MyBlankProject
hyla new -b -d ~/hyla/MyBlankProject --force
cd ~/hyla/MyBlankProject

echo "Add asciidoc files"
hyla new -b -d MyBlankProject --force
hyla create --t asciidoc --a article --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a book --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a image --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a audio --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a video --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a source --d ~/hyla/MyBlankProject
hyla create --t asciidoc --a table --d ~/hyla/MyBlankProject

echo "Change style in the _config.yaml file"
ruby -i.bak -pe 'sub(%r{style: liberation},"style: foundation")' _config.yaml

echo "Generate HTML content"
hyla generate

echo "Revert style"
ruby -i.bak -pe 'sub(%r{style: foundation},"style: liberation")' _config.yaml