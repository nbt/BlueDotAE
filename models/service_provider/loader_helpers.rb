require 'zip/zip'
module ServiceProvider

  module LoaderHelpers

    # Unzip a page of data and return as a string.  Implentation note:
    # as Zip::ZipFile only reads from a file, we write the page to a
    # tmpfile first.
    #
    # TODO: convert to ZipInputStream so we don't have to write to a
    # tmpfile.
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

end
