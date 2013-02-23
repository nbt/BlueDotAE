require 'json'

class WeatherStation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  has n, :weather_observations
  property :callsign, String
  property :station_type, String
  property :lat, Decimal, :precision => 9, :scale => 6
  property :lng, Decimal, :precision => 9, :scale => 6
  property :altitude_m, Decimal, :precision => 9, :scale => 2
  property :created_at, DateTime
  property :updated_at, DateTime

  WUNDERGROUND_API_KEY = '61a01f40daa1353f'

  # DataMapper::Model.raise_on_save_failure = true

  # From wikipedia: "the meridian length of 1 degree of latitude on
  # the sphere is 111.2 km," so if we truncate latitude to 0.01'ths
  # (0.001ths), we have a resolution of 1.1km (0.11km).  We could
  # exploit this to limit the number of different queries we make for
  # nearby weather stations.
  
  def self.find_stations_near(lat, lng)
    uri = "http://api.wunderground.com/api/#{WUNDERGROUND_API_KEY}/geolookup/q/#{lat},#{lng}.json"
    response = WebCaches::WeatherStation.fetch(uri) {|uri|
      # TODO: rate-limit queries
      # TODO: retry / ignore some responses
      Net::HTTP.get_response(URI(uri))
    }
    # TODO: better error
    raise RuntimeError.new("could not fetch #{uri}") unless (response && response.code == "200")
    process_stations(response.body)
  end

  def self.process_stations(json)
    hash = JSON.load(json)
    nearby = hash["location"]["nearby_weather_stations"]
    process_airport_stations(nearby["airport"]["station"]) + 
      process_pws_stations(nearby["pws"]["station"])
  end

  def self.process_airport_stations(stations)
    stations.map do |station|
      process_station("airport", station["icao"], station["lat"], station["lon"])
    end
  end

  def self.process_pws_stations(stations)
    stations.map do |station|
      process_station("pws", station["id"], station["lat"], station["lon"])
    end
  end

  def self.process_station(station_type, callsign, lat, lng)
    # workaround for https://github.com/datamapper/dm-validations/issues/51
    lat1 = BigDecimal(lat.to_f.round(6).to_s)
    lng1 = BigDecimal(lng.to_f.round(6).to_s)
    WeatherStation.first_or_create({:callsign => callsign, :station_type => station_type},
                                   {:lat => lat1, :lng => lng1})
  end
end
