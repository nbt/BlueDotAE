FactoryGirl.define do

  factory :account do
    name
    email
    role "admin"
    password "password"
  end

  factory :client do
    name
  end

  factory :meter_reading do
    service_account
  end

  factory :premises do
    client
  end    
  
  factory :service_account do
    premises
    loader_class "SDGE"
  end

  factory :premises_weather_station_adjacency do
    premises
    weather_station
  end

  factory :weather_station do
    sequence(:callsign) {|n| sprintf("K%03d", n) }
    station_type "pws"
  end

  factory :weather_observation do
    weather_station
  end
    
end
