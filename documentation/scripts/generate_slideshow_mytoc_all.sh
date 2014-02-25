#!/bin/sh

#./generate_slideshow_mytoc_all.sh ~/MyProjects/hyla/data/toc.adoc MyTocProject
echo "Create MyToc Project"
echo "Using parameters"
source create_adoc_from_toc.sh $1 $2

cd ~/hyla/MyTocProject

# echo "Generate slideshow for a module using deckjs as backend"
hyla generate --backend deckjs -s  . -d generated_content_deckjs -r index2html
open ~/hyla/MyTocProject/generated_content_deckjs/my-project_AllSlides.html

# echo "Generate slideshow for a module using revealjs as backend"
hyla generate --backend revealjs -s  . -d generated_content_reveal -r index2html

open ~/hyla/MyTocProject/generated_content_reveal/my-project_AllSlides.html