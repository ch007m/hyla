#!/bin/sh

source remove_temp_directories.sh

echo "Create a Blank project but containing the yaml config file"
cd ~/hyla
hyla new -b -d MyBlankProject --force
cd MyBlankProject

echo "Change destination parameter"
ruby -i.bak -pe 'sub(%r{destination: generated_content},"destination: .")' _config.yaml

hyla create -a book -c ~/hyla/my_config_html.yaml

echo "Project created"
ls -la ~/hyla/MyBlankProject

echo "Revert destination parameter"
ruby -i.bak -pe 'sub(%r{destination: .},"destination: generated_content")' _config.yaml



