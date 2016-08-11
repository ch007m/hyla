#!/bin/sh

echo "Remove MyRevealJS"
rm -rf ~/hyla/MyRevealSlideShow
cd ~/hyla

echo "Create a blank project"
hyla new -b MyRevealSlideShow

echo "Create from slideshow template a RevealJS  file"
hyla add --t slideshow -a revealjs -d MyRevealSlideShow

echo "Generate HTML5 Slideshow content"
cd MyRevealSlideShow

echo "Copy logo"
cp -r /Users/chmoulli/hyla/RevealCreatedContent/image ./image

echo "Change theme to GPE"
ruby -i.bak -pe 'sub(%r{revealjs_theme: deault},"revealjs_theme: gpe")' _config.yaml

hyla generate --backend revealjs -s . -d generated_content -r adoc2html --trace

echo "Open the slideshow using your web browser"
# open http://localhost:4000/hyla/slideshow_revealjs.html &

echo "Start web server"
# hyla serve -P 4000 -H localhost -b /hyla/ -d generated_content/

echo "Change theme to GPE"
ruby -i.bak -pe 'sub(%r{revealjs_theme: gpe},"revealjs_theme: default")' _config.yaml

