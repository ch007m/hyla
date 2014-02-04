#!/bin/sh

echo "Generate HTML Content of MyBlank project"
echo "Styles availables : liberation, asciidoctor, colony, foundation, foundation-lime, foundation-potion, github, golo, iconic, maker, readthedocs, riak, rocket-panda, rubygems"

cd ~/hyla/MyBlankProject

echo "Change style in the _config.yaml file"
ruby -i.bak -pe 'sub(%r{style: liberation},"style: foundation")' _config.yaml

echo "Generate HTML content"
hyla generate

echo "Revert style"
ruby -i.bak -pe 'sub(%r{style: foundation},"style: liberation")' _config.yaml