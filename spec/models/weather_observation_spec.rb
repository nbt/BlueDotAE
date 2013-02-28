require 'spec_helper'
require 'vcr_helper'

describe "WeatherObservation Model" do
  before(:each) do
    reset_db
    @airport_station = FactoryGirl.create(:weather_station, :callsign => "KLAX", :station_type => "airport")
    @pws_station = FactoryGirl.create(:weather_station, :callsign => "KCAMANHA3", :station_type => "pws")
  end

  it 'can be created' do
    weather_observation = FactoryGirl.create(:weather_observation)
    weather_observation.should_not be_nil
    weather_observation.should be_saved
  end
  
  describe "WundergroundPWS" do
    it "should have empty observations before" do
      WeatherObservation.count.should == 0
    end

    it "should load a month of observations" do
      WeatherObservation.count.should == 0
      VCR.use_cassette(example.metadata[:full_description]) do
        WeatherObservation.etl(@pws_station, Time.local(2012, 3, 4))
      end
      WeatherObservation.count.should == 31
    end

    it 'uses caching to avoid extra web transactions' do
      # make sure that we DO get an error on HTTP access not covered
      # by a VCR cassette.
      expect {
        WeatherObservation.etl(@pws_station, Time.local(2012, 1, 1, 23, 2))
      }.to raise_error(VCR::Errors::UnhandledHTTPRequestError)
      # Cache the extracted data.
      VCR.use_cassette(example.metadata[:full_description]) do
        WeatherObservation.etl(@pws_station, Time.local(2012, 1, 1, 23, 2))
      end
      # Now make sure that caching short-circuits the HTTP access
      expect { 
        WeatherObservation.etl(@pws_station, Time.local(2012, 1, 1, 23, 2)) 
      }.to_not raise_error
    end

    it 'does not create duplicate entries' do
      VCR.use_cassette(example.metadata[:full_description]) do
        WeatherObservation.etl(@pws_station, Time.local(2012, 1, 1, 23, 2))
      end
      WeatherObservation.count.should == 31
      # load again
      VCR.use_cassette(example.metadata[:full_description]) do
        WeatherObservation.etl(@pws_station, Time.local(2012, 1, 1, 23, 2))
      end
      WeatherObservation.count.should == 31
    end

  end

  describe "WundergroundAirport" do
    it "should have empty observations before" do
      WeatherObservation.count.should == 0
    end

    it "should load a month of observations" do
      WeatherObservation.count.should == 0
      VCR.use_cassette(example.metadata[:full_description]) do
        WeatherObservation.etl(@airport_station, Time.local(2012, 3, 4))
      end
      WeatherObservation.count.should == 31
    end

  end

end
