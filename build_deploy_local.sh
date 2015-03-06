#!/bin/sh

gem build hyla.gemspec
ruby -e "Dir.glob('*.gem').each {|i| puts exec(\"gem install #{i} --no-rdoc --no-ri\")}"