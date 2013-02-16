require 'spec_helper'
require 'vcr_helper'

describe "SDGE Loader Model" do

  it 'should load Green Button usage data' do
    loader = ServiceProvider::SDGELoader.new("05219047", 
                                             Time.new(2012, 1, 1), 
                                             {"user_id" => "ChrisWrightFamily", "password" => "SDGEolus1402"})
    readings = nil
    VCR.use_cassette(example.metadata[:full_description]) do
      expect {readings = loader.extract_meter_readings}.to_not raise_error
    end
    readings.should be_kind_of(Mechanize::File)
    records = loader.translate_meter_readings(readings)
    records.should be_kind_of(Array)
    records.length.should == 744
    records.first[:value].should == 1010.0
  end

end
