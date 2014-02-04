#!/bin/sh

echo "Remove MyRevealJS"
rm -rf ~/hyla/MyRevealSlideShow
cd ~/hyla

echo "Create a blank project"
hyla new --blank -d MyRevealSlideShow

echo "Create from slideshow template a RevealJS  file"
hyla create --t slideshow -a revealjs -d MyRevealSlideShow

echo "Generate HTML5 Slideshow content"
cd MyRevealSlideShow

hyla generate --backend revealjs -s . -d generated_content -r adoc2slide

echo "Open the slideshow using your web browser"
open http://localhost:4000/hyla/slideshow_revealjs.html &

echo "Start web server"
hyla serve -P 4000 -H localhost -b /hyla/ -d generated_content/

