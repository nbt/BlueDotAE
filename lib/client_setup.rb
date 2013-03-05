require 'location_services'
require 'zillow_services'

# Jump-start populating the db.  Later, this will be a form-based
# web page.
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
                                      :altitude_m => geocoded_attributes[:altitude_m],
                                      :zillow_attributes => zillow_attributes
                                      )
    
    # Attach ServiceAccounts to the Premises (we assume same user_id and
    # password for each)
    meter_ids.each do |meter_id|
      service_account = premises.service_accounts.create(:service_provider_class => "SDGE",
                                                         :credentials => {
                                                           "user_id" => user_id,
                                                           "password" => Base64::strict_decode64(user_pw),
                                                           "meter_id" => meter_id})
      # Fetch all available billing data from remote site(s)
      $stderr.puts("fetching billing data for #{meter_id}")
      service_account.fetch_billing_data
    end
    
    # Discover / create weather stations in vicinity of premises
    weather_stations = premises.find_weather_stations
    $stderr.puts("found #{weather_stations.count} stations")
    
    # Fetch daily weather observations for proximate weather stations
    weather_stations.each do |station|
      $stderr.puts("update observations for #{station.callsign}")
      station.update_observations
    end
    
  end

end
