require 'time_utilities'

class WeatherHistory
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial

  def fetch(station_id, start_time, frequency = :daily)
  end

  class Wunderground < WeatherHistory

    def fetch(station_id, start_time, frequency = :daily)
      quantization = get_quantization(frequency)
      start_time = TimeUtilities.quantize_time(start_time, quantization)
      uri = make_uri(station_id, start_time, frequency)
      WebCache.with_db_catche(uri) {|uri| Net::HTTP.get(URI(uri)) }
    end

    def get_quantization(frequency)
      case frequency
      when :daily
        :year
      when :hourly
        :day
      else
        raise ArgumentError.new("frequency must be :daily or :hourly, found #{frequency.inspect}")
      end
    end

    def make_uri(station_id, start_time, frequency)
      s = "http://www.wunderground.com/"
      if (is_airport?(station_id))
        case frequency
        when :daily
          s + "history/airport/#{station_id}/#{start_time.year}/1/1/CustomHistory.html?dayend=31&monthend=12&yearend=#{start_time.year}&format=1"
        when :hourly
          s + "history/airport/#{station_id}/#{start_time.year}/#{start_time.month}/#{start_time.day}/DailyHistory.html?format=1"
        end
      else
        case frequency
        when :daily
          s + "weatherstation/WXDailyHistory.asp?ID=#{station_id}&graphspan=custom&month=1&day=1&year=#{start_time.year}&monthend=12&dayend=31&yearend=#{start_time.year}&format=1"
        when :hourly
          s = "weatherstation/WXDailyHistory.asp?ID=#{station_id}&month=#{start_time.month}&day=#{start_time.day}&year=#{start_time.year}&format=1"
        end
      end
    end

  end

end
