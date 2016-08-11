#!/bin/sh

echo "Remove MyRevealJS"
rm -rf ~/hyla/MyRevealSlideShow
cd ~/hyla

echo "Create a blank project"
hyla new -b MyRevealSlideShow

echo "Create from slideshow template a RevealJS project"
hyla add --t slideshow -a revealjs -d MyRevealSlideShow

echo "Generate HTML5 Slideshow content"
cd MyRevealSlideShow

echo "Change theme to Conference, backend to reveal"
ruby -i.bak -pe 'sub(%r{revealjs_theme: gpe},"revealjs_theme: conference")' _config.yaml
ruby -i.bak -pe 'sub(%r{backend: html5},"backend: revealjs")' _config.yaml
ruby -i.bak -pe 'sub(%r{rendering: adoc2html},"rendering: adoc2html")' _config.yaml

hyla generate

echo "Copy logo"
cp -r /Users/chmoulli/hyla/RevealCreatedContent/image ./generated_content/image

echo "Open the slideshow using your web browser"
open http://localhost:4000/hyla/readme.html &

echo "Start web server"
hyla serve -P 4000 -H localhost -b /hyla/ -out_dir generated_content/

