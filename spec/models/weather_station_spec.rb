require 'spec_helper'
require 'vcr_helper'

describe "WeatherStation Model" do
  before(:each) do
    WebCache.destroy!
    WeatherStation.destroy!
  end

  let(:weather_station) { WeatherStation.new }

  it 'can be created' do
    weather_station.should_not be_nil
  end

  describe "find_stations_near" do
    before(:each) do
      @lat = "41.547372"
      @lng = "-71.164176"
      @airport_station_count = 4
      @pws_station_count = 32
    end
    
    it 'finds the correct stations' do
      WeatherStation.count.should == 0
      VCR.use_cassette("WeatherStation find_stations_near finds the correct station") do
        stations = WeatherStation.find_stations_near(@lat, @lng)
        stations.size.should == @airport_station_count + @pws_station_count
      end
    end

    it 'should save stations in database' do
      WeatherStation.count.should == 0
      VCR.use_cassette("WeatherStation find_stations_near should save stations in database") do
        s = WeatherStation.find_stations_near(@lat, @lng)
      end
      WeatherStation.count.should == @airport_station_count + @pws_station_count
    end

  end

end
