require 'spec_helper'
require 'vcr_helper'

describe "Premises Model" do
  LA = {:lat => 33.888389, :lng => -118.4111556}
  LA_COUNT = 38
  MA = {:lat => 42.368813, :lng => -71.0893229}
  PA = {:lat => 39.947488, :lng => -75.178526}
  SF = {:lat => 37.7747645, :lng => -122.4292645}
  SF_COUNT = 39

  before(:each) { reset_db }

  it 'can be created' do
    premises = FactoryGirl.create(:premises)
    premises.should_not be_nil
    premises.should be_saved
  end

  describe 'Premises.stale_weather_stations' do
    
    it 'should return Premises records whose x is nil or in the past' do
      past = DateTime.new(2010, 1, 1)
      now = DateTime.new(2010, 1, 2)
      future = DateTime.new(2010, 1, 3)

      pa = FactoryGirl.create(:premises, :find_weather_stations_at => past)
      pb = FactoryGirl.create(:premises, :find_weather_stations_at => future)
      pc = FactoryGirl.create(:premises, :find_weather_stations_at => nil)
    
      Premises.stale_weather_stations(now).should =~ [pa, pc]
    end

  end

  describe 'find_weather_stations' do

    it 'creates associations' do
      la = FactoryGirl.create(:premises, LA)
      sf = FactoryGirl.create(:premises, SF)
      VCR.use_cassette("Premises_find_weather_station_creates_associations", 
                       :match_requests_on => [:method, :uri, :query],
                       :tag => :with_time_frozen) do
        begin
          la.find_weather_stations_at.should be_nil
          expect {la.find_weather_stations}.to_not raise_error
          la.weather_stations.count.should == LA_COUNT
          la.find_weather_stations_at.should > DateTime.now
          expect {sf.find_weather_stations}.to_not raise_error
          sf.weather_stations.count.should == SF_COUNT
          sf.find_weather_stations_at.should > DateTime.now
        ensure
          Timecop.return
        end
      end
    end

  end

  describe 'nightly_task' do

    it 'succeeds on valid premises' do
      FactoryGirl.create(:premises, LA)
      Premises.any_instance.should_receive(:find_weather_stations_aux).and_return([])
      logging_data = with_output_captured { Premises.nightly_task }
      logging_data[:stderr].should =~ /success/
    end

    it 'logs error on invalid premises' do
      FactoryGirl.create(:premises)
      logging_data = with_output_captured { Premises.nightly_task }
      logging_data[:stderr].should =~ /error/
    end

  end

end
