#!/bin/sh

source remove_temp_directories.sh

echo "Create a Blank project but containing the yaml config file"
cd ~/hyla
hyla new -b -d MyBlankProject --force
cd MyBlankProject

echo "Change destination parameter"
ruby -i.bak -pe 'sub(%r{destination: generated_content},"destination: .")' _config.yaml

hyla create --a article
hyla create --a book
hyla create --a image
hyla create --a audio
hyla create --a video
hyla create --a source
hyla create --a table

echo "Project created"
ls -la ~/hyla/MyBlankProject

echo "Revert destination parameter"
ruby -i.bak -pe 'sub(%r{destination: .},"destination: generated_content")' _config.yaml



