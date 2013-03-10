require 'spec_helper'
require 'vcr_helper'

describe ClientSetup do
  before(:each) do
    reset_db
  end
  
  describe "setup" do 
    it 'creates an account without error' do
      
      VCR.use_cassette(example.metadata[:full_description] + "-00", :match_requests_on => [:method, :uri, :query]) do
        Premises.count.should == 0
        ServiceAccount.count.should == 0
        
        ClientSetup.setup("Chris Wright", 
                          "1402 EOLUS AVE, ENCINITAS, CA 92024", 
                          "ChrisWrightFamily", 
                          "U0RHRW9sdXMxNDAy", 
                          ["01046957", "05219047"])        

        Premises.count.should == 1
        ServiceAccount.count.should == 2
        premises = Premises.first

        premises.lat.should_not be_nil
        premises.lng.should_not be_nil
        premises.elevation_m.should_not be_nil
      end

      VCR.use_cassette(example.metadata[:full_description] + "-01", :match_requests_on => [:method, :uri, :query]) do
        WeatherStation.count.should == 0

        Premises.nightly_task
        $stderr.puts("WeatherStation.count = #{WeatherStation.count}")

        WeatherStation.count.should == 39
        wss = WeatherStation.all
        wss.any? {|ws| ws.lat.nil? }.should be_false
        wss.any? {|ws| ws.lng.nil? }.should be_false
        wss.any? {|ws| ws.elevation_m.nil? }.should be_false
      end

      VCR.use_cassette(example.metadata[:full_description] + "-02", :match_requests_on => [:method, :uri, :query]) do
        WebCaches::SDGE::BillDetail.count.should == 0
        WebCaches::SDGE::BillSummary.count.should == 0
        WebCaches::SDGE::MeterReading.count.should == 0

        ServiceAccount.nightly_task

        WebCaches::SDGE::BillDetail.count.should == 50
        WebCaches::SDGE::BillSummary.count.should == 50
        WebCaches::SDGE::MeterReading.count.should == 50
      end

      VCR.use_cassette(example.metadata[:full_description] + "-03", :match_requests_on => [:method, :uri, :query]) do
        WeatherObservation.count.should == 0

        WeatherStation.nightly_task
        $stderr.puts("WeatherObservation.count = #{WeatherObservation.count}")

        WeatherObservation.count.should == 21892
      end


    end
  end

end
