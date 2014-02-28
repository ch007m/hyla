# encoding: utf-8

require 'fileutils'

class ConcatenateHtmlToPdf

  module_name = ARGV[0] if !ARGV[0].nil? || !ARGV[0].empty?
  source = ARGV[1] if !ARGV[1].nil? || !ARGV[1].empty?
  destination = ARGV[2] if !ARGV[2].nil? || !ARGV[2].empty?
  output_file = module_name + ".pdf"

  footer_text = "Copyright ©2014 Red Hat, Inc."
  header_html = "file:///Users/chmoulli/hyla/header_redhat_logo.html"
  #header_html = "file:///Users/chmoulli/hyla/images/rhheader_thin.png"


  list_of_files = ""

  unless File.directory?(destination)
    FileUtils.mkdir_p(destination)
  end

  filter = source + "*.html"

  files = Dir[filter]
  # files = files.sort.map { |file| file[1] }
  files.each do |file|
    list_of_files = list_of_files + " " + file
  end

  Dir.chdir(source) do
    system "wkhtmltopdf #{list_of_files} #{destination}/#{output_file} --footer-center '#{footer_text}' --header-html '#{header_html}' "
  end



end