module LocationServices
  extend self

  class ETLError < StandardError ; end

  GEOCODER = "http://maps.googleapis.com/maps/api/geocode"
  
  # Return an array of possible matches on raw_address
  def fetch_geocoded_attributes(raw_address, web_agent = BlueDotBot.new)
    query = "#{GEOCODER}/json?address=#{CGI.escape(raw_address)}&sensor=false&region=US"
    page = web_agent.get(query)
    json = page.body
    # File.open("/tmp/x.json", "w") {|f| f.print(json)}
    # here, json is a JSON data structure returned by google geocoder.
    raise(ETLError, 'null reply') unless json && (response = JSON.load(json))
    raise(ETLError, response["status"]) unless response["status"] == "OK"
    raise(ETLError, 'empty results') unless (results = response["results"]) && results.size > 0
    results.map {|r| create_geocoded_attributes(r, web_agent)}.compact
  end

  # See http://code.google.com/apis/maps/documentation/geocoding/ for
  # format. Return a hash with lots of useful geocoded fields.
  def create_geocoded_attributes(json, web_agent)
    raise(ETLError, 'cannot find street-level results') unless json["types"].member?("street_address")
    components = json["address_components"]

    lat = normalize_lat(Float(json['geometry']['location']['lat']))
    lng = normalize_lng(Float(json['geometry']['location']['lng']))

    {:address => json["formatted_address"],
      :city => find_component_with_type(components, "locality", "long_name"),
      :county => find_component_with_type(components, "administrative_area_level_2", "long_name"),
      :state => find_component_with_type(components, "administrative_area_level_1", "short_name"),
      :country => find_component_with_type(components, "country", "short_name"),
      :postal_code => find_component_with_type(components, "postal_code", "long_name"),
      :lat => lat,
      :lng => lng
    }.merge(fetch_elevation(lat, lng, web_agent))
  end
  
  def normalize_lat(val)
    val
  end

  def normalize_lng(val)
    ((val + 180.0) % 360.0) - 180.0
  end

  def find_component_with_type(components, type, form)
    (component = components.find {|h| h["types"].member?(type)}) && component[form]
  end
  
  ELECODER = "http://maps.googleapis.com/maps/api/elevation"
    
  def fetch_elevation(lat, lng, web_agent = BlueDotBot.new)
    lng = normalize_lng(Float(lng))    # there are some odd numbers out there!
    query = "#{ELECODER}/json?locations=#{lat},#{lng}&sensor=false"
    page = web_agent.get(query)
    json = page.body
    # here, json is a JSON data structure returned by google elevation service
    raise(ETLError, 'null reply') unless json && (response = JSON.load(json))
    raise(ETLError, response["status"]) unless response["status"] == "OK"
    raise(ETLError, 'empty results') unless (results = response["results"]) && results.size > 0
    raise(ETLError, "missing elevation") unless (elevation = results.first["elevation"])
    {:elevation_m => elevation, :resolution => results.first["resolution"]}
  end

end
