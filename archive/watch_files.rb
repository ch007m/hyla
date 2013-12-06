require 'listen'
require 'asciidoctor'
require 'erb'

class WatchFiles

  DEFAULT_OPTIONS = {
      :watch_dir => '.',
      :watch_ext => %w(ad adoc asc asciidoc),
      :run_on_start => false,
      :backend => 'html5',
      :eruby => 'erb',
      :doctype => 'article',
      :compact => false,
      :attributes => {},
      :always_build_all => false,
      :to_dir => '.',
      :to_file => '',
      :safe => :unsafe
  }

  def initialize
    puts "2. Class initialized !"
  end

  def watch()

    puts "3. Watch function called"

    @opts = DEFAULT_OPTIONS.clone

    callback = Proc.new do |modified, added, removed|
      puts "modified absolute path: #{modified}"
      puts "added absolute path: #{added}"
      puts "removed absolute path: #{removed}"

      if !modified.nil? or !added.nil?

        modified.each do |modify|
          puts "File modified : #{modify}"

          to_dir = File.dirname(modify)
          @opts[:to_dir] = to_dir

          file_to_process = Pathname.new(modify)
          file_basename = file_to_process.basename
          @ext_name = File.extname(file_basename)

          puts "Extension of the file : #{@ext_name}"

          if @ext_name != '.html'
            to_file = file_to_process.to_s.gsub('adoc', 'html')
            puts "Output Directory: #{to_dir}"
            puts "To File : #{to_file}"
            @opts[:to_file] = to_file
            Asciidoctor.render_file(modify, @opts)
          end
        end
      end


    end

    listener = Listen.to!('../../data/generated', &callback)

  end
end

puts "1. Call & start Listen"
WatchFiles.new.watch