require 'spec_helper'
require 'vcr_helper'

describe LocationServices do

  describe 'fetch_geocoded_attributes' do
    it 'returns an array of hashes' do
      VCR.use_cassette("LocationServices_fetch_geocoded_attributes_0") do
        attrs = LocationServices.fetch_geocoded_attributes("438 Webster Street, San Francisco, CA")
        attrs.first.should == {
          :address=>"438 Webster Street, San Francisco, CA 94117, USA", 
          :city=>"San Francisco", 
          :county=>"San Francisco", 
          :state=>"CA", 
          :country=>"US", 
          :postal_code=>"94117", 
          :lat=>37.7749285, 
          :lng=>-122.4291429, 
          :elevation_m=>50.3736572265625, 
          :resolution=>0.5964969992637634
        }
      end
    end
  end

  describe 'fetch_elevation' do

    it 'returns a hash' do
      VCR.use_cassette("LocationServices_fetch_elevation_0") do
        attrs = LocationServices.fetch_elevation(37.7749285, -122.4291429)
        attrs.should == {
          :elevation_m=>50.3736572265625, 
          :resolution=>0.5964969992637634
        }
      end
    end

  end

end

