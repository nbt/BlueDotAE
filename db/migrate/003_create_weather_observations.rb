migration 3, :create_weather_observations do
  up do
    create_table :weather_observations do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :weather_observations
  end
end
