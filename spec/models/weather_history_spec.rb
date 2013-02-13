require 'spec_helper'
require 'vcr_helper'

describe "WeatherHistory Model" do
  before(:each) do
    WebCache.destroy
  end
  let(:weather_history) { WeatherHistory.new }
  it 'can be created' do
    weather_history.should_not be_nil
  end
  
  describe "Wunderground" do
    it 'can fetch daily pws data' do
      VCR.use_cassette('WeatherHistory::Wunderground can fetch daily pws data') do
        resp = WeatherHistory::Wunderground.fetch("KCAMANHA3", Time.local(2012, 3, 4), :daily)
        resp.code.should == "200"
        records = resp.body.split("\n")
        records.length.should == 726
      end
    end

    it 'can fetch hourly pws data' do
      VCR.use_cassette('WeatherHistory::Wunderground can fetch hourly pws data') do
        resp = WeatherHistory::Wunderground.fetch("KCAMANHA3", Time.local(2012, 1, 1), :hourly)
        resp.code.should == "200"
        records = resp.body.split("\n")
        records.length.should == 564
      end
    end

    it 'can fetch daily airport data' do
      VCR.use_cassette('WeatherHistory::Wunderground can fetch daily airport data') do
        resp = WeatherHistory::Wunderground.fetch("KLAX", Time.local(2012, 3, 4), :daily)
        resp.code.should == "200"
        records = resp.body.split("\n")
        records.length.should == 368
      end
    end

    it 'can fetch hourly airport data' do
      VCR.use_cassette('WeatherHistory::Wunderground can fetch hourly airport data') do
        resp = WeatherHistory::Wunderground.fetch("KLAX", Time.local(2012, 1, 1, 23, 2), :hourly)
        resp.code.should == "200"
        records = resp.body.split("\n")
        records.length.should == 43
      end
    end

    it 'rejects unrecognized frequency' do
      expect { WeatherHistory::Wunderground.fetch("KLAX", Time.local(2012, 1, 1), :weekly) }.to raise_error(ArgumentError)
    end

    it 'uses caching to avoid extra web transactions' do
      # make sure that we DO get an error on HTTP access not covered
      # by a VCR cassette.
      expect {
        WeatherHistory::Wunderground.fetch("KLAX", Time.local(2012, 1, 1, 23, 2), :hourly)
      }.to raise_error(VCR::Errors::UnhandledHTTPRequestError)
      # Cache the fetched data.
      VCR.use_cassette('WeatherHistory::Wunderground uses caching to avoid extra web transactions') do
        WeatherHistory::Wunderground.fetch("KLAX", Time.local(2012, 1, 1, 23, 2), :hourly)
      end
      # Now make sure that caching short-circuits the HTTP access
      expect { 
        WeatherHistory::Wunderground.fetch("KLAX", Time.local(2012, 1, 1, 23, 2), :hourly) 
      }.to_not raise_error
    end

  end
  
end
