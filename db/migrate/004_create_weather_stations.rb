migration 4, :create_weather_stations do
  up do
    create_table :weather_stations do
      column :id, Integer, :serial => true
      column :callsign, String, :length => 255
      column :station_type, String, :length => 255
      column :lat, Decimal
      column :lng, Decimal
      column :altitude_m, Decimal
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end

  down do
    drop_table :weather_stations
  end
end
