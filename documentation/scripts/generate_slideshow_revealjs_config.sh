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

echo "Change theme to GPE, backend to reveal"
ruby -i.bak -pe 'sub(%r{revealjs_theme: default},"revealjs_theme: gpe")' _config.yaml
ruby -i.bak -pe 'sub(%r{backend: html5},"backend: revealjs")' _config.yaml
ruby -i.bak -pe 'sub(%r{rendering: adoc2html},"rendering: adoc2htmlslide")' _config.yaml

hyla generate

echo "Copy logo"
cp -r /Users/chmoulli/hyla/RevealCreatedContent/image ./generated_content/image

echo "Open the slideshow using your web browser"
# open http://localhost:4000/hyla/slideshow_revealjs.html &

echo "Start web server"
# hyla serve -P 4000 -H localhost -b /hyla/ -d generated_content/

echo "Change theme to GPE"
#ruby -i.bak -pe 'sub(%r{revealjs_theme: gpe},"revealjs_theme: default")' _config.yaml
#ruby -i.bak -pe 'sub(%r{backend: revealjs},"backend: html5")' _config.yaml
#ruby -i.bak -pe 'sub(%r{rendering: adoc2htmlslide},"rendering: adoc2html")' _config.yaml

