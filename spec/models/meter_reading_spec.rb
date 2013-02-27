require 'spec_helper'

describe "MeterReading Model" do
  before(:each) { reset_db }

  let(:meter_reading) { MeterReading.new }
  it 'can be created' do
    meter_reading.should_not be_nil
  end
end
