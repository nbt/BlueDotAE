migration 3, :create_weather_histories do
  up do
    create_table :weather_histories do
      column :id, Integer, :serial => true
      
    end
  end

  down do
    drop_table :weather_histories
  end
end
