require 'spec_helper'
require 'vcr_helper'

describe "SDGE Loader Model" do
  before(:each) do
    @service_account = double().tap {|o|
      o.stub(:id => 1,
             :loader_class => "SDGELoader",
             :credentials => {
               "user_id" => "ChrisWrightFamily", 
               "password" => "SDGEolus1402",
               "meter_id" => "05219047"})}
  end

  it 'should load Green Button usage data' do
    loader = ServiceProvider::SDGELoader.new(@service_account,
                                             Time.new(2012, 1, 1))
    readings = nil
    VCR.use_cassette(example.metadata[:full_description]) do
      expect {readings = loader.extract_meter_readings}.to_not raise_error
    end
    readings.should be_kind_of(Mechanize::File)
    records = loader.translate_meter_readings(readings)
    records.should be_kind_of(Array)
    records.length.should == 744
    records.first[:quantity].should == 1010.0
  end

  it 'should create Meter Reading records' do
    MeterReading.destroy
    ServiceAccount.destroy
    service_account = ServiceAccount.create(:loader_class => "SDGELoader",
                                            :credentials => {
                                              "user_id" => "ChrisWrightFamily", 
                                              "password" => "SDGEolus1402",
                                              "meter_id" => "05219047"})
    VCR.use_cassette(example.metadata[:full_description]) do
      expect {
        service_account.etl_meter_readings(Time.new(2012, 1, 1))
      }.to_not raise_error
    end
    MeterReading.count.should == 744
    MeterReading.first[:quantity].should == 1010.0
    MeterReading.first.service_account.should == service_account
  end

end
