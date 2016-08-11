#!/bin/sh

echo "Generate HTML Content of MyBlank project"
echo "Styles availables : liberation, asciidoctor, colony, foundation, foundation-lime, foundation-potion, github, golo, iconic, maker, readthedocs, riak, rocket-panda, rubygems"

echo "Create Project"
rm -rf ~hyla/MyBlankProject
hyla new -b ~/hyla/MyBlankProject --force
cd ~/hyla/MyBlankProject

echo "Add asciidoc files"
hyla add --t asciidoc --a article --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a book --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a image --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a audio --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a video --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a source --d ~/hyla/MyBlankProject
hyla add --t asciidoc --a table --d ~/hyla/MyBlankProject

echo "Change style in the _config.yaml file"
#ruby -i.bak -pe 'sub(%r{style: liberation},"style: foundation")' _config.yaml
ruby -i.bak -pe 'sub(%r{footer_copyright:},"footer_copyright: Copyright ©2014 My Company, Inc.")' _config.yaml
ruby -i.bak -pe 'sub(%r{header_image_path:},"header_image_path: image/rhheader_thin.png")' _config.yaml
ruby -i.bak -pe 'sub(%r{revealjs_theme:},"revealjs_theme: gpe")' _config.yaml

echo "Copy logo"
mkdir -p generated_content/image
cp /Users/chmoulli/hyla/RevealCreatedContent/images/rhheader_thin.png ./generated_content/image/

echo "Generate HTML content"
hyla generate

#echo "Revert style"
#ruby -i.bak -pe 'sub(%r{style: foundation},"style: liberation")' _config.yaml