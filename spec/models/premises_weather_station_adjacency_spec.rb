require 'spec_helper'

describe "PremisesWeatherStationAdjacency Model" do
  before(:each) { reset_db }

  it 'can be created' do
    premises_weather_station_adjacency = FactoryGirl.create(:premises_weather_station_adjacency)
    premises_weather_station_adjacency.should_not be_nil
    premises_weather_station_adjacency.should be_saved
  end

  it 'has a weather_station and a premises' do
    premises_weather_station_adjacency = FactoryGirl.create(:premises_weather_station_adjacency)
    premises_weather_station_adjacency.premises.should be_instance_of(Premises)
    premises_weather_station_adjacency.weather_station.should be_instance_of(WeatherStation)
  end

  it 'creates a has n relation to premises and weather_station' do
    pwsa = FactoryGirl.create(:premises_weather_station_adjacency)
    pwsa.premises.weather_stations.should =~ [pwsa.weather_station]
    pwsa.weather_station.premises.should =~ [pwsa.premises]
  end

end
