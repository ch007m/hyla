#!/bin/sh

echo "Generate HTML Content of MyBlank project"
cd ~/hyla/MyBlankProject

echo "Backup _config.yaml file as we don't use it here"
mv _config.yaml _config.yaml.bk

hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content

echo "Revert _config.yaml file"
mv _config.yaml.bk _config.yaml