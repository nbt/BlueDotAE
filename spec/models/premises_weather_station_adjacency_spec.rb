require 'spec_helper'

describe "PremisesWeatherStationAdjacency Model" do
  before(:each) { reset_db }

  let(:premises_weather_station_adjacency) { PremisesWeatherStationAdjacency.new }
  it 'can be created' do
    premises_weather_station_adjacency.should_not be_nil
  end
end
