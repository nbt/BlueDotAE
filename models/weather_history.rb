require 'net/http'

class WeatherHistory
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial

  def self.fetch(station_id, start_time, frequency = :daily)
  end

  class Wunderground < WeatherHistory

    def self.fetch(station_id, start_time, frequency = :daily)
      uri = make_uri(station_id, start_time, frequency)
      WebCache.with_db_cache(uri) {|uri| Net::HTTP.get_response(URI(uri)) }
    end

    def self.make_uri(sid, st, frequency)
      s = "http://www.wunderground.com/"
      case frequency
      when :daily
        # month at a time, starting on the 1st of the month
        if (is_airport?(sid))
          s += "history/airport/KUUU/#{st.year}/#{st.month}/1/MonthlyHistory.html?format=1"
        else
          s += "weatherstation/WXDailyHistory.asp?ID=#{sid}&graphspan=month&month=#{st.month}&day=1&year=#{st.year}&format=1"
        end
      when :hourly
        # day at a time, starting at midnight
        if (is_airport?(sid))
          s += "history/airport/#{sid}/#{st.year}/#{st.month}/#{st.day}/DailyHistory.html?format=1"
        else
          s += "weatherstation/WXDailyHistory.asp?ID=#{sid}&month=#{st.month}&day=#{st.day}&year=#{st.year}&format=1"
        end
      else
        raise ArgumentError.new("frequency must be :month or :day, found #{frequency.inspect}") 
      end
      s
    end

    def self.is_airport?(sid)
      sid =~ /\AK...\Z/
    end

  end

end
