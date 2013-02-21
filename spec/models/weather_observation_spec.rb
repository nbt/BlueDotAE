require 'spec_helper'
require 'vcr_helper'

describe "WeatherObservation Model" do
  before(:each) do
    WebCache.destroy!
    WeatherObservation.destroy!
    @airport_station = double().tap {|o| 
      o.stub(:id => 1, :callsign => "KLAX", :station_type => "airport")
    }
    @pws_station = double().tap {|o| 
      o.stub(:id => 1, :callsign => "KCAMANHA3", :station_type => "pws")
    }
  end
  let(:weather_observation) { WeatherObservation.new }
  it 'can be created' do
    weather_observation.should_not be_nil
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
