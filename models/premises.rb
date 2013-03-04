class Premises
  include DataMapper::Resource

  # properties
  property :id, Serial
  property :address, String
  property :find_weather_stations_at, DateTime
  property :lat, Decimal, :precision => 9, :scale => 6
  property :lng, Decimal, :precision => 9, :scale => 6

  # associations
  belongs_to :client, :key => true
  has n, :service_accounts, :constraint => :destroy
  has n, :premises_weather_station_adjacencies, :constraint => :destroy
  has n, :weather_stations, :through => :premises_weather_station_adjacencies

  FIND_WEATHER_STATIONS_INTERVAL = 120 # check for new weather stations every 120 days

  def self.stale_weather_stations(now = DateTime.now)
    self.all(:find_weather_stations_at => nil) | self.all(:find_weather_stations_at.lt => now)
  end

  def self.nightly_task
    self.stale_weather_stations.each do |premises|
      begin
        $stderr.print("Premises(#{premises.id}).find_weather_stations...")
        stations = premises.find_weather_stations
        $stderr.print("found #{stations.count} stations...success\n")
      rescue => e
        $stderr.print("error: #{e.message}\n")
        $stderr.print(e.backtrace.join("\n"))
      end
    end
  end

  def find_weather_stations
    # start with a clean slate
    self.premises_weather_station_adjacencies.destroy
    stations = WeatherStation.find_stations_near(self.lat, self.lng)
    stations.each do |station| 
      pwsa = PremisesWeatherStationAdjacency.create!(:premises => self, :weather_station => station)
    end
    self.find_weather_stations_at = DateTime.now + FIND_WEATHER_STATIONS_INTERVAL
    self.save
    stations
  end


end
