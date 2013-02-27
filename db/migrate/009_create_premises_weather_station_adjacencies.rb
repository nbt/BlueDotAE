migration 9, :create_premises_weather_station_adjacencies do
  up do
    create_table :premises_weather_station_adjacencies do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :premises_weather_station_adjacencies
  end
end
