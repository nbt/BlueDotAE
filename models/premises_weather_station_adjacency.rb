class PremisesWeatherStationAdjacency
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  belongs_to :premises, 'Premises'
  belongs_to :weather_station, 'WeatherStation'

end
