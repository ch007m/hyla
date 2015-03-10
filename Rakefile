libdir = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

#require 'compass'
#require 'compass/sass_compiler'

# Dir["#{dir}/*.scss"].select do | f |
#   p "File : #{f}"
#   Compass.add_configuration({
#                                 :sass_dir => '.',
#                                 :css_dir => 'styles',
#                                 :fonts_dir => 'fonts',
#                                 :output_style => :compressed
#                             }, 'alwaysmin' # A name for the configuration, can be anything you want
#   )
#   Compass.sass_compiler.compile(f.to_s, '#{f.to_s}.css')
# end

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'bundler/version'
require 'sass'
require 'hyla/configuration'
require 'font-awesome-sass'

#############################################################################
#
# Helper functions
#
#############################################################################
def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  line = File.read("lib/#{name}/project.rb")[/^\s*VERSION\s*=\s*.*/]
  line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
end

def date
  Date.today.to_s
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

def sass_assets
  Hyla::Configuration.assets
end

def default_compilation_style
  'compressed'
end

#
# Compass Style Values to generate the CSS file : nested, expanded, compact, compressed
#

style = ENV["STYLE"] || "nested"

#############################################################################
#
# Standard tasks
#
#############################################################################
Rake::TestTask.new do |t|
  t.libs << 'test'
end

# Simple Test case
task :test do
  ruby "test/my_test.rb"
end

desc "Run tests"
task :default => :test

# Generate CSS files
task :compass do
  puts "\n## Compiling Sass"

  path = Gem.loaded_specs['font-awesome-sass'].full_gem_path + "/assets/stylesheets"

  #Go to the compass project directory
  Dir.chdir File.join(sass_assets, "sass") do |dir|
    puts "Sass dir : #{dir}"
    system "compass compile --fonts-dir 'fonts' --css-dir 'styles' --sass-dir '.' -s #{style} -I #{path}"
  end
end

# Build the Gem
task :build do
  system "gem build #{gemspec_file}"
end

# Build the Gem & deploy it locally
task :install => :build do
  system "gem install #{gem_file} -l"
end

# Build the Gem, install it locally & push it
task :deploy => :install do
  system "gem push #{gem_file}"
end

# Build the Gem and move it under the pkg directory
task :build_pkg => :gemspec do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end
