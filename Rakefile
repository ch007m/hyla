libdir = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'sass'
require 'hyla/configuration'
require 'rake/minify'

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

def revealjs_redhat_css_theme_assets
  [Hyla::Configuration.assets, 'revealjs-redhat', 'lib', 'css'] * '/'
end

def revealjs_css_theme_assets
  [Hyla::Configuration.assets, 'revealjs', 'css', 'theme'] * '/'
end

def revealjs_css_vendor_assets
  [Hyla::Configuration.assets, 'revealjs', 'lib', 'css'] * '/'
end

def default_compilation_style
  'compressed'
end

#
# Compass Style Values to generate the CSS file : nested, expanded, compact, compressed
#
style = ENV["STYLE"] || "nested"
tag_release = ENV["TAG_RELEASE"] || "#{name}-#{version}"

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

desc "Generate CSS files"
task :compass, [:mode] do |t, args|
  mode = args.mode || 'development'
  
  if mode == "development"
     output_style = 'expanded'
  else
     output_style = 'compact'
  end
 
  puts "\n## Compiling Sass"

  # path = Gem.loaded_specs['font-awesome-sass'].full_gem_path + "/assets/stylesheets"

  #Go to the compass project directory
  Dir.chdir File.join(sass_assets, "sass") do |dir|
    puts "Sass dir : #{dir}"
    # -s #{style} -I #{path}
    # To generate the sourcemap --> --sourcemap
    # puts "compass compile --fonts-dir 'fonts' --css-dir 'styles' --sass-dir '.' -e #{mode} --output-style=#{output_style} --force"
    system "compass compile --fonts-dir 'fonts' --css-dir 'styles' --sass-dir '.' -e #{mode} --output-style=#{output_style} --force"

    # Copy css to RevealJS theme
    # p revealjs_css_assets
    sh "cp styles/old-gpe.css #{revealjs_css_theme_assets}"
    sh "cp styles/font-awesome.css #{revealjs_css_vendor_assets}/font-awesome-4.3.0.css"

    sh "cp styles/new-gpe.css #{revealjs_redhat_css_theme_assets}/gpe.css"
    sh "cp styles/conference.css #{revealjs_redhat_css_theme_assets}/conference.css"
    sh "cp styles/conference-redhat.css #{revealjs_redhat_css_theme_assets}/conference-redhat.css"
    sh "cp styles/theme-v2-liberation.css #{revealjs_redhat_css_theme_assets}/theme-v2-liberation.css"
    sh "cp styles/theme-v2-overpass.css #{revealjs_redhat_css_theme_assets}/theme-v2-overpass.css"
    sh "cp styles/theme-output.css #{revealjs_redhat_css_theme_assets}/theme-output.css"
    sh "cp styles/font-awesome.css #{revealjs_redhat_css_theme_assets}/font-awesome-4.3.0.css"

    # sh "cp gpe.scss #{revealjs_css_theme_assets}"
    # sh "cp styles/old-gpe.css.map #{revealjs_css_theme_assets}"
    # sh "cp styles/font-awesome.css.map #{revealjs_css_vendor_assets}/font-awesome-4.3.0.css.map"

  end

end

desc "Build the Gem"
task :build do
  system "gem build #{gemspec_file}"
end

desc "Build the Gem & deploy it locally"
task :install => :build do
  system "gem install #{gem_file} -l"
end

desc "Build the Gem, install it locally & push it"
task :deploy => :install do
  system "gem push #{gem_file}"
end

desc "Tag Hyla release to github repo"
task :tag_release do
  system "git tag -a #{name}-#{version} -m 'Release of hyla #{version}'"
  system "git push origin #{name}-#{version}"
end

desc "Delete the git tag"
task :tag_delete, [:version] do |t, args|
  version = args.version or
       fail "version is mandatory"
  p "Tag to be removed: #{version}"
  sh "git tag -d #{version}"
  sh "git push origin :#{version}"
end

desc "Build the Gem and move it under the pkg directory"
task :build_pkg do
  sh "mkdir -p pkg"
  sh "gem build #{gemspec_file}"
  sh "mv #{gem_file} pkg"
end

#
# Generate doc for gh-pages
#
desc "Commit the local site to the gh-pages branch and publish to GitHub Pages"
task :publish do
  # Ensure the gh-pages dir exists so we can generate into it.
  puts "Checking for gh-pages dir..."
  unless File.exist?("./gh-pages")
    puts "Creating gh-pages dir..."
    sh "git clone git@github.com:cmoulliard/hyla.git gh-pages"
  end

  # Ensure latest gh-pages branch history.
  Dir.chdir('gh-pages') do
    sh "git checkout gh-pages"
    sh "git pull origin gh-pages"
  end

  # Proceed to purge all files in case we removed a file in this release.
  puts "Cleaning gh-pages directory..."
  purge_exclude = %w[
      gh-pages/.
      gh-pages/..
      gh-pages/.git
      gh-pages/.gitignore
    ]
  FileList["gh-pages/{*,.*}"].exclude(*purge_exclude).each do |path|
    sh "rm -rf #{path}"
  end

  # Copy site to gh-pages dir.
  puts "Building site into gh-pages branch..."

  # Generate HTML site using hyla
  sh "hyla generate -c config.yaml"

  # Commit and push.
  puts "Committing and pushing to GitHub Pages..."
  sha = `git rev-parse HEAD`.strip

  Dir.chdir('gh-pages') do
    sh "git add ."
    sh "git commit --allow-empty -m 'Updating to #{sha}.'"
    sh "git push origin gh-pages"
  end
  puts 'Done.'
end

Rake::Minify.new(:minifyjs) do
  dir("lib/resources/assets/revealjs/js/debug") do
    add("lib/resources/assets/revealjs/js/reveal.min.js", "reveal.js")
  end
  dir("lib/resources/assets/revealjs-redhat/lib/js/debug") do
    add("lib/resources/assets/revealjs-redhat/lib/js/reveal.min.js", "reveal.js")
    add("lib/resources/assets/revealjs-redhat/lib/js/head.min.js", "head.js")
    add("lib/resources/assets/revealjs-redhat/lib/js/gpe.min.js", "gpe.js")
  end
end

# desc 'Say Hello'
# task :hello, [:msg1, :msg2] do |t, args|
#   msg1 = args.msg1 or
#       fail "Msg1 is mandatory"
#   msg2 = args[:msg2] || "Man"
#   puts msg1.upcase + '!'
#   puts msg2.downcase + '!'
# end
