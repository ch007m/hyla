#!/bin/sh

source remove_temp_directories.sh

echo "Create a Blank project but containing the yaml config file"
cd ~/hyla
hyla new -b -d MyBlankProject --force
cd MyBlankProject

hyla add -a book -c ~/hyla/my_config_html.yaml

echo "Project created"
ls -la ~/hyla/MyBlankProject


