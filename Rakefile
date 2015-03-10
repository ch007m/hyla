libdir = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'bundler/version'
require 'sass'
require 'hyla/configuration'

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


def sass_config
  [sass_assets, "config.rb"] *'/'
end

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

# Build the Gem
task :build do
  system "gem build #{gemspec_file}"
end

# Build the Gem & deploy it locally
task :install => :build do
  system "gem install #{gem_file} -l"
end

# Generate CSS files
task :compass_compressed do
  puts "\n## Compiling Sass - #{sass_config}"
  #Go to the compass project directory
  Dir.chdir File.join(sass_assets, "sass") do |dir|
    system "compass compile -c #{sass_config}"
  end
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
