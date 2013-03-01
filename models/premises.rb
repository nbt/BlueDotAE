class Premises
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :address, String
  belongs_to :client, :key => true
  has n, :service_accounts, :constraint => :destroy
  has n, :premises_weather_station_adjacencies, :constraint => :destroy
  has n, :weather_stations, :through => :premises_weather_station_adjacencies

end
