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

    # convert Feb 22, 10 => Time.zone.parse("22-Feb-2010")
    def translate_month_day_year(raw_date_string)
      match = (raw_date_string =~ /(\w*) (\d*), (\d*)/)
      raise(RecordError.new("unrecognized date format in #{raw_date}")) unless match
      year = year_in_century_to_year_with_century($3.to_i)
      DateTime.parse("#{$2}-#{$1}-#{year}")
    end
      
    # convert mm/dd/yyyy or mm/dd/yy to timestamp
    def translate_mmddyy(mddyy_date)
      mddyy_date =~ %r!(\d{1,2})/(\d{1,2})/(\d{2,4})!
      raise(RecordError.new("unrecognized date format in #{mddyy_date}")) unless mddyy_date
      month, day, year = $1.to_i, $2.to_i, $3.to_i
      year = year_in_century_to_year_with_century(year)
      DateTime.parse("#{year}-#{month}-#{day}")
    end
    
    # Convert a 'century-less' year (a 2 digit value) to century and a
    # year (a 4 digit value, at least for the next 7989 years).  Assumes
    # `year` is in the current year or in the past.
    def year_in_century_to_year_with_century(year)
      this_year = Time.now.year
      this_year_in_century = this_year % 100
      this_century = this_year - this_year_in_century
      
      if (year >= 100)
        year
      elsif (year > this_year_in_century)
        this_century - 100 + year
      else
        this_century + year
      end
    end
    
    
  end


end

