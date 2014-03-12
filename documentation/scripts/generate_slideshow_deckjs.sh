#!/bin/sh

echo "Remove MyDeckSlideShow"
rm -rf  ~/hyla/MyDeckSlideShow
cd ~/hyla

echo "Create a blank project"
hyla new -b -d MyDeckSlideShow

echo "Create from slideshow template a DeckJS  file"
hyla add --t slideshow -a deckjs -d MyDeckSlideShow

echo "Generate HTML5 Slideshow content"
hyla generate --backend deckjs -s ~/hyla/MyDeckSlideShow -d ~/hyla/MyDeckSlideShow/generated_content -r adoc2html -a deckjs_theme=swiss,deckjs_transition=fade

# hyla generate --backend deckjs -s  ~/hyla/MyDeckSlideShow -d ~/hyla/MyDeckSlideShow/generated_content -r adoc2html
# hyla generate --backend deckjs -s  ~/hyla/MyDeckSlideShow -d ~/hyla/MyDeckSlideShow/generated_content -r adoc2html -a deckjs_theme=web-2.0,deckjs_transition=horizontal-slide

