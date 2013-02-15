module ServiceProvider

  class LoaderBase
    include LoaderHelpers

    # load one month of meter readings for the given meter_id
    def self.etl_meter_readings(meter_id, start_time, access_credentials)
      self.new(meter_id, start_time, access_credentials).etl_meter_readings
    end
    
    # load one monthly bill for the given meter_id
    def self.etl_service_bill(meter_id, start_time, access_credentials)
      self.new(meter_id, start_time, access_credentials).etl_service_bill
    end
    
    attr_reader :meter_id, :start_time, :access_credentials, :options, :web_agent
    
    def initialize(meter_id, start_time, access_credentials, options = {})
      @meter_id = meter_id
      @start_time = start_time
      @access_credentials = access_credentials
      @options = options
      # ----
      @web_agent = BlueDotBot.new
      @web_agent.set_proxy('localhost', @options[:proxy_port]) if @options[:proxy_port].present?
      # Some sites are particular about the Accept fields in the requests.
      @web_agent.request_headers = {
        'User-Agent' => BlueDotBot::BLUE_DOT_BOT_AGENT,
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'en-us,en;q=0.5',
        'Accept-Encoding' => 'gzip, deflate',
        'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
      }
    end

    def etl_meter_readings
      self.load_meter_readings(self.translate_meter_readings(self.extract_meter_readings()))
    end
    
    # Return a raw HTTP response whose body contains meter readings
    def extract_meter_readings
    end
    
    # translate a raw HTTP response into an array of hash objects,
    # suitable for instantiation as MeterReading objects
    def translate_meter_readings(http_response)
    end
    
    # Each hash in the list of hashes represents a meter reaading.
    # Commit to the MeterReading table if not already present and
    # return a list of MeterReading objects.
    def load_meter_readings(hashes)
      hashes.map do |h|
        r = MeterReading.first_or_create({:service_provider => self.class.to_s,
                                           :meter_id => h[:meter_id],
                                           :date => h[:date]},
                                         h)
        raise RecordError.new("failed to save #{r.inspect}: #{r.errors.full_messages}") unless r.id
      end
    end
    
  end

end
