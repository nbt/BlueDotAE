require 'location_services'
require 'zillow_services'

# Jump-start populating the db.  Later, this will be a form-based
# web page.  After calling this, you may call:
#
# ServiceAccount.nightly_task - to fetch billing data
# Premises.nightly_task - to find weather stations
# WeatherStation.nightly_task - to update observations
#
# If these are too heavy-handed, create a method in
# Premises that does updates only on the relevant 
# service_accounts and weather_stations

module ClientSetup
  extend self

  def setup(user_name, raw_address, user_id, user_pw, meter_ids)
    client = Client.first_or_create(:name => user_name)

    # Glean everything we can from the raw_address
    geocoded_attributes_list = LocationServices.fetch_geocoded_attributes(raw_address)
    geocoded_attributes = geocoded_attributes_list.first
    $stderr.puts("geocoded attributes = #{geocoded_attributes}")
    zillow_attributes = ZillowServices.fetch_zillow_attributes(geocoded_attributes[:address])
    $stderr.puts("zillow attributes = #{zillow_attributes}")

    # Install a Premises in the db
    premises = client.premises.create(:raw_address => raw_address,
                                      :lat => geocoded_attributes[:lat],
                                      :lng => geocoded_attributes[:lng],
                                      :elevation_m => geocoded_attributes[:elevation_m],
                                      :zillow_attributes => zillow_attributes
                                      )
    
    # Attach ServiceAccounts to the Premises (we assume same user_id and
    # password for each)
    meter_ids.each do |meter_id|
      service_account = premises.service_accounts.create(:service_provider_class => "SDGE",
                                                         :credentials => {
                                                           "user_id" => user_id,
                                                           "password" => Base64::strict_decode64(user_pw)},
                                                         :subaccount => meter_id)
    end
    
  end

end
