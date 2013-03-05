require 'spec_helper'
require 'vcr_helper'
require 'zillow_services'

describe ZillowServices do

  describe 'fetch_zillow_attributes' do
    it 'returns a hash of attributes' do
      VCR.use_cassette("ZillowServices_fetch_zillow_attributes_0") do
        attrs = ZillowServices.fetch_zillow_attributes("438 Webster Street, San Francisco, CA 94117, USA")
        attrs.should == {
          :square_feet=>"1188", 
          :year_built=>"1990", 
          :building_type=>"Condominium", 
          :occupancy=>"2"
        }
      end
    end
  end

end

