require 'net/http'

class WeatherObservation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  belongs_to :weather_station
  property :date, DateTime
  property :temperature_max_f, Float
  property :temperature_avg_f, Float
  property :temperature_min_f, Float
  property :dewpoint_max_f, Float
  property :dewpoint_avg_f, Float
  property :dewpoint_min_f, Float
  property :humidity_max, Float
  property :humidity_avg, Float
  property :humidity_min, Float
  property :pressure_max_in, Float
  property :pressure_avg_in, Float
  property :pressure_min_in, Float
  property :windspeed_max_mph, Float
  property :windspeed_avg_mph, Float
  property :precipitation_in, Float

  def self.fetch(station_id, start_time, frequency = :daily)
  end

  class Wunderground < WeatherObservation

    # extract the raw HTML (really psuedo-CSV)
    def self.extract(station, start_time, frequency = :daily)
      uri = make_uri(station.callsign, start_time, frequency)
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
