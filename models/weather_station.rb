require 'json'

class WeatherStation
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  has n, :premises_weather_station_adjacencies, :constraint => :destroy
  has n, :premises, 'Premises', :through => :premises_weather_station_adjacencies
  has n, :weather_observations, :constraint => :destroy
  property :callsign, String
  property :station_type, String
  property :lat, Float
  property :lng, Float
  property :elevation_m, Float
  property :last_fetched_at, DateTime
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

  # Load weather observations for each weather station that is
  # out of date relative to its associated service accounts.
  def self.nightly_task
    self.all.each { |station| station.update_observations }
  end

  # private (not really)

  def update_observations
    service_accounts = self.service_accounts
    start_date = nil
    end_date = nil
    # Find earliest and latest billing dates for each service account
    # associated with this weather station
    service_accounts.each do |s|
      start_date = s.start_date if (!s.start_date.nil? && (start_date.nil? || s.start_date < start_date))
      end_date = s.end_date if (!s.end_date.nil? && (end_date.nil? || s.end_date > end_date))
    end
    # $stderr.puts("#{self.callsign}: has #{service_accounts.count} service accounts, start=#{start_date}, end=#{end_date}")
    return unless start_date && end_date
    # TODO: if calling etl on each station is too expensive, create
    # WeatherStation.start_date and WeatherStation.end_date columns
    # and test against those before doing ETL.
    date = DateTime.new(start_date.year, start_date.month)
    $stderr.puts("Fetching weather observations for #{self.callsign} between #{date.iso8601} and #{end_date.iso8601}")
    while (date < end_date)
      WeatherObservation.etl(self, date)
      date = date.next_month
    end
  end
  
  def service_accounts
    self.premises.map {|p| p.service_accounts}.flatten
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
    w = WeatherStation.first(:callsign => callsign, :station_type => station_type)
    unless w
      w = WeatherStation.create(:callsign => callsign, 
                                :station_type => station_type,
                                :lat => lat,
                                :lng => lng,
                                :elevation_m => get_elevation(callsign, lat, lng))
      unless w
        raise(StandardError.new("cannot create weather station: #{w.errors}"))
      end
    end
    w
  end

  private

  def self.get_elevation(callsign, lat, lng)
    $stderr.print("Elevation for WeatherStation #{callsign} @ #{lat}, #{lng} = ")
    attrs = LocationServices.fetch_elevation(lat, lng)
    elevation_m = attrs[:elevation_m]
    $stderr.puts(elevation_m)
    elevation_m
  end

end
