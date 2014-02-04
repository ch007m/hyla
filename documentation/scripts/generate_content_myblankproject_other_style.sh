#!/bin/sh

echo "Generate HTML Content of MyBlank project - Style Foundation"
cd ~/hyla/MyBlankProject

echo "Backup _config.yaml file as we don't use it here"
mv _config.yaml _config.yaml.bk

#hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content --style liberation
#hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content --style github
hyla generate -r adoc2html -s ~/hyla/MyBlankProject/ -d ~/hyla/MyBlankProject/generated_content -y foundation

echo "Revert _config.yaml file"
mv _config.yaml.bk _config.yaml
