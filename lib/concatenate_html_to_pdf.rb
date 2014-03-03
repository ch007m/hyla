# encoding: utf-8

require 'fileutils'

class ConcatenateHtmlToPdf

  module_name = ARGV[0] if !ARGV[0].nil? || !ARGV[0].empty?
  source = ARGV[1] if !ARGV[1].nil? || !ARGV[1].empty?
  destination = ARGV[2] if !ARGV[2].nil? || !ARGV[2].empty?
  output_file = module_name + ".pdf"

  footer_text = "Copyright ©2014 Red Hat, Inc."
  header_html = "file:///Users/chmoulli/hyla/resources/header_logo.html"
  cover_url = '/Users/chmoulli/RedHat/GPE/content/fsw/1_Composite_Applications/generated_content/p01m1title.html'

  list_of_files = ""

  unless File.directory?(destination)
    FileUtils.mkdir_p(destination)
  end

  filter = source + "*.html"
  files = Dir[filter]

  files.each do |file|
    file_name = File.basename file
    next if file_name.include?('assessments')
    next if file_name.include?('labinstructions')
    next if file_name.include?('title')
    list_of_files = list_of_files + " " + file
  end

  puts list_of_files

  Dir.chdir(source) do
    system "wkhtmltopdf #{list_of_files} #{destination}/#{output_file} --header-html '#{header_html}' --margin-top '18' --page-size 'A4' --footer-center '#{footer_text}' --margin-bottom '10mm' --cover '#{cover_url}'"
  end

end