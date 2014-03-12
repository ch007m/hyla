#!/bin/sh

source remove_temp_directories.sh

echo "Create a Blank project but containing the yaml config file"
cd ~/hyla
hyla new -b -d MyBlankProject --force
cd MyBlankProject

echo "Change destination parameter"
ruby -i.bak -pe 'sub(%r{destination: generated_content},"destination: .")' _config.yaml
ruby -i.bak -pe 'sub(%r{# header_image_path: },"header_image_path: image/rhheader_thin.png ")' _config.yaml
ruby -i.bak -pe 'sub(%r{# footer_copyright: },"footer-copyright: Copyright ©2014 Red Hat, Inc.")' _config.yaml

hyla add --a article
hyla add --a book
hyla add --a image
hyla add --a audio
hyla add --a video
hyla add --a source
hyla add --a table

echo "Copy header file"
mkdir image
cp ~/hyla/RevealCreatedContent/images/rhheader_thin.png image/

echo "Project created"
ls -la ~/hyla/MyBlankProject

echo "Revert destination parameter"
ruby -i.bak -pe 'sub(%r{destination: .},"destination: generated_content")' _config.yaml



