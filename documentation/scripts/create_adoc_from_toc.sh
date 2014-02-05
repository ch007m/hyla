#!/bin/sh

# ./create_adoc_from_toc.sh ~/MyProjects/hyla/data/toc.adoc MyTocProject

source remove_temp_directories.sh

if [ "$#" == "0" ]; then
    echo "No arguments provided"
    echo "Usage : ./create_adoc_from_toc.sh path_to_toc_file project_name"
    exit 1
fi

echo "TOC file location : $1"
echo "Project Name : $2"

hyla generate -r toc2adoc -p my-project -d ~/hyla/$2/ --toc $1
hyla generate -r adoc2html -s ~/hyla/$2/ -d ~/hyla/$2/generated_content

echo "Project created"
ls -la ~/hyla/$2
