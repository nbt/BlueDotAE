# require 'zip/zip'
module ServiceProvider

  module LoaderHelpers

=begin
    # Unzip a page of data and return as a string.  Implentation note:
    # as Zip::ZipFile only reads from a file, we write the page to a
    # tmpfile first.
    #
    # TODO: convert to ZipInputStream so we don't have to write to a
    # tmpfile.  See ZipFile.open_buffer() in 
    # ~/Developer/Turquoise/usr/lib/ruby/gems/1.9.1/gems/rubyzip-0.9.9/lib/zip/zip_file.rb:106

    def unzip(page, opts = {:encoding => 'ascii-8bit'})
      "".tap do |str|
        Tempfile.open("unzip", :encoding => opts[:encoding]) do |tmpfile|
          tmpfile.write(page)
          Zip::ZipFile.foreach(tmpfile.path()) do |zip_entry|
            zip_entry.get_input_stream {|io| str << io.read}
          end
        end
      end
    end
  end
=end

require 'zipruby'

    def unzip(page)
      {}.tap do |h|
        Zip::Archive.open_buffer(page) do |archive|
          archive.each {|entry| h[entry.name] = entry.read }
        end
      end
    end

  end


end

