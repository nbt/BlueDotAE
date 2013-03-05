require 'net/http'
require 'csv'

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

  class Loader
    attr_reader :weather_station, :start_time

    def initialize(weather_station, start_time)
      @weather_station = weather_station
      @start_time = start_time
    end

    def etl
      self.load(self.translate(self.extract()))
    end

    def extract
      uri = create_uri
      WebCaches::WeatherObservation.fetch(uri) {|uri|
        Net::HTTP.get_response(URI(uri))
      }
    end

    # Return a URI to query the remote site
    def create_uri
    end

    # Return a list of hashes for the extracted data
    def translate(response)
    end

    # Records is a list hashes.  If new, commit to db, else fetch the
    # incumbent from the db.
    def load(records)
      records.map do |h| 
        r = WeatherObservation.first_or_create({:weather_station_id => h[:weather_station_id], :date => h[:date]}, h)
        if (r.id.nil?)
          $stderr.puts("failed to save #{r.inspect}, #{r.errors.full_messages}")
        end
      end
    end

  end

  class WundergroundPWS < Loader

    PWS_MAP = { 
      :date => lambda {|row, loader| DateTime.parse(row[:date])},
      :weather_station_id => lambda {|row, loader| loader.weather_station.id},
      :temperature_max_f => lambda {|row, loader| row[:temperaturehighf]}, 
      :temperature_avg_f => lambda {|row, loader| row[:temperatureavgf]}, 
      :temperature_min_f => lambda {|row, loader| row[:temperaturelowf]}, 
      :dewpoint_max_f => lambda {|row, loader| row[:dewpointhighf]},
      :dewpoint_avg_f => lambda {|row, loader| row[:dewpointavgf]}, 
      :dewpoint_min_f => lambda {|row, loader| row[:dewpointlowf]}, 
      :humidity_max => lambda {|row, loader| row[:humidityhigh]}, 
      :humidity_avg => lambda {|row, loader| row[:humidityavg]}, 
      :humidity_min => lambda {|row, loader| row[:humiditylow]}, 
      :pressure_max_in => lambda {|row, loader| row[:pressuremaxin]}, 
      :pressure_avg_in => lambda {|row, loader| (row[:pressuremaxin] + row[:pressureminin]) * 0.5},
      :pressure_min_in => lambda {|row, loader| row[:pressureminin]}, 
      :windspeed_max_mph => lambda {|row, loader| row[:windspeedmaxmph]}, 
      :windspeed_avg_mph => lambda {|row, loader| row[:windspeedavgmph]}, 
      :precipitation_in => lambda {|row, loader| (p = row[:precipitationsumin]) == 'T' ? 0.01 : p}
    }
    
    # This URI will fetch one month of daily weather information,
    # starting on the first day of the month specified by start_time.
    def create_uri
      "http://www.wunderground.com/" +
        "weatherstation/WXDailyHistory.asp?" + 
        "ID=#{weather_station.callsign}&" +
        "graphspan=month&" + 
        "month=#{start_time.month}&day=1&year=#{start_time.year}" +
        "&format=1"
    end

    CSV_OPTIONS = {:headers => true, :converters => :numeric, :header_converters => :symbol}

    def translate(response)
      raise LoadError.new("empty body") if (str = (response && response.body)).nil?
      table = CSV.parse(str.gsub("<br>","").gsub("\n\n","\n").strip, CSV_OPTIONS)
      table.map {|day| translate_day(day) }
    end

    def translate_day(csv_row)
      hash = {}.tap {|h| PWS_MAP.each {|k, v| h[k] = v.call(csv_row, self)}}
    end

  end

  class WundergroundAirport < Loader

    AIRPORT_MAP = { 
      :date => lambda {|row, loader| DateTime.parse(row[0])},
      :weather_station_id => lambda {|row, loader| loader.weather_station.id},
      :temperature_max_f => lambda {|row, loader| row[:max_temperaturef]}, 
      :temperature_avg_f => lambda {|row, loader| row[:mean_temperaturef]}, 
      :temperature_min_f => lambda {|row, loader| row[:min_temperaturef]}, 
      :dewpoint_max_f => lambda {|row, loader| row[:max_dew_pointf]},
      :dewpoint_avg_f => lambda {|row, loader| row[:meandew_pointf]}, 
      :dewpoint_min_f => lambda {|row, loader| row[:min_dewpointf]}, 
      :humidity_max => lambda {|row, loader| row[:max_humidity]}, 
      :humidity_avg => lambda {|row, loader| row[:_mean_humidity]}, 
      :humidity_min => lambda {|row, loader| row[:_min_humidity]}, 
      :pressure_max_in => lambda {|row, loader| row[:_max_sea_level_pressurein]}, 
      :pressure_avg_in => lambda {|row, loader| row[:_mean_sea_level_pressurein]},
      :pressure_min_in => lambda {|row, loader| row[:_min_sea_level_pressurein]}, 
      :windspeed_max_mph => lambda {|row, loader| row[:_max_wind_speedmph]}, 
      :windspeed_avg_mph => lambda {|row, loader| row[:_mean_wind_speedmph]}, 
      :precipitation_in => lambda {|row, loader| (p = row[:precipitationsumin]) == 'T' ? 0.01 : p}
    }
    
    def create_uri
      "http://www.wunderground.com/" +
        "history/airport/#{weather_station.callsign}/" + 
        "#{start_time.year}/#{start_time.month}/1/MonthlyHistory.html?format=1"
    end

    CSV_OPTIONS = {:headers => true, :converters => :numeric, :header_converters => :symbol}

    def translate(response)
      raise LoadError.new("empty body") if (str = (response && response.body)).nil?
      table = CSV.parse(str.gsub("<br />","").strip, CSV_OPTIONS)
      table.map {|day| translate_day(day) }
    end

    def translate_day(csv_row)
      hash = {}.tap {|h| AIRPORT_MAP.each {|k, v| h[k] = v.call(csv_row, self)}}
    end

  end

  LOADER_CLASSES = {"pws" => WundergroundPWS, "airport" => WundergroundAirport}

  def self.etl(weather_station, start_time)
    LOADER_CLASSES[weather_station.station_type].new(weather_station, start_time).etl
    weather_station.last_fetched_at = DateTime.now
    weather_station.save
  end
    
end
