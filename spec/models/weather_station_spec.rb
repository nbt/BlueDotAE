require 'spec_helper'
require 'vcr_helper'

describe "WeatherStation Model" do
  before(:each) { reset_db }

  it 'can be created' do
    weather_station = FactoryGirl.create(:weather_station)
    weather_station.should_not be_nil
    weather_station.should be_saved
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

  describe 'update_observations' do
    before(:each) do
      @date1 = DateTime.new(2010, 1, 1)
      @date2 = DateTime.new(2010, 3, 1)
      @date3 = DateTime.new(2010, 5, 1)

      @date1a = DateTime.new(2010, 2, 1)
      @date2a = DateTime.new(2010, 4, 1)

      @weather_station = FactoryGirl.create(:weather_station)
      @service_account1 = double("service account 1",
                                 :id => 1,
                                 :start_date => @date1,
                                 :end_date => @date2)
      @service_account2 = double("service account 2",
                                 :id => 2,
                                 :start_date => @date2,
                                 :end_date => @date3)
    end

    it 'should load weather observations spanning entire range of dates' do  
      @weather_station.stub(:service_accounts).and_return([@service_account1, @service_account2])
      WeatherObservation.should_receive(:etl).with(@weather_station, @date1)
      WeatherObservation.should_receive(:etl).with(@weather_station, @date1a)
      WeatherObservation.should_receive(:etl).with(@weather_station, @date2)
      WeatherObservation.should_receive(:etl).with(@weather_station, @date2a)
      @weather_station.update_observations
    end

    it 'should not error if there are no service accounts' do
      @weather_station.stub(:service_accounts).and_return([])
      expect { @weather_station.update_observations}.to_not raise_error
    end

  end

end
