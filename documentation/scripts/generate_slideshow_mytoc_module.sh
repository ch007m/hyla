#!/bin/sh

#./generate_slideshow_mytoc_module.sh  ~/MyProjects/hyla/data/toc.adoc MyTocProject
echo "Create MyToc Project"
echo "Using parameters"
source create_adoc_from_toc.sh $1 $2

echo "Generate slideshow for a module using deckjs as backend"
cd ~/hyla/MyTocProject
hyla generate --backend deckjs -s  A_Introduction_module/ -d A_Introduction_module/generated_content -r index2htmlslide