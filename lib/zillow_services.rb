module ZillowServices
  extend self

  class ETLError < StandardError; end
  
  class ETLLoadError < StandardError; end
  
  # see http://www.zillow.com/howto/api/GetDeepSearchResults.htm
  ZILLOW_WEB_SERVICES_ID = "X1-ZWz1d1nuco0v0r_8w9nb"
  ZILLOW_WEB_SERVICES_URL = "http://www.zillow.com/webservice/GetDeepSearchResults.htm"
  BUILDING_TYPES = [
                    ['Single Family', 'SingleFamily'],
                    ['Townhouse', 'Townhouse'], # not documented, but generated...
                    ['Duplex', 'Duplex'],
                    ['Triplex', 'Triplex'],
                    ['Quadruplex', 'Quadruplex'],
                    ['Condominium', 'Condominium'],
                    ['Cooperative', 'Cooperative'],
                    ['Mobile', 'Mobile'],
                    ['Multi-Family (2 to 4)', 'MultiFamily2To4'],
                    ['Multi-Family (5 Plus)', 'MultiFamily5Plus'],
                    ['Timeshare', 'Timeshare'],
                    ['Miscellaneous', 'Miscellaneous'],
                    ['Vacant Residential Land', 'VacantResidentialLand'],
                    ['Unknown', 'Unknown'],
                   ]
  
  def fetch_zillow_attributes(address, web_agent = BlueDotBot.new)
    raise(ETLLoadError, 'malformed address') unless (address =~ /(.*?),.*?(\d*),\s*USA/)
    street_address = $1
    postal_code = $2
    query = ZILLOW_WEB_SERVICES_URL +
      "?zws-id=" + ZILLOW_WEB_SERVICES_ID +
      "&address=" + CGI::escape(street_address) + 
      "&citystatezip=" + CGI::escape(postal_code)
    page = web_agent.get(query)
    xml = page.body
    candidates = find_candidates(xml)
    best_candidate(candidates)
  end

  # Return an array of hashes with :square_feet, :year_built, etc in
  # each hash.
  def find_candidates(xml)
    doc = Nokogiri::XML(xml)
    if (doc.xpath('//message/code').inner_text != "0")
      errmsg = doc.xpath('//message/text').inner_text
      raise(ETLLoadError, errmsg)
    end
    doc.xpath('//response/results/result').map do |r|
      {
        :square_feet => r.xpath('finishedSqFt').inner_text,
        :year_built => r.xpath('yearBuilt').inner_text,
        :building_type => r.xpath('useCode').inner_text,
        :occupancy => r.xpath('bedrooms').inner_text
      }
    end
  end

  # zillow returns an array of possible results.  As a heuristic, the
  # best one is the one that has all four fields (square_feet,
  # year_built, building_type, occupancy).  if we don't find a result
  # with all the fields, we accumulate what we've seen in best{}.
  def best_candidate(candidates)
    best = {}
    candidates.each do |c|
      return c if c[:square_feet] && c[:year_built] && c[:building_type] && c[:occupancy]
      best = c.merge(best)
    end
    best
  end

end
