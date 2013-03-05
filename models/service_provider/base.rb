module ServiceProvider

  class Base
    include Helpers

    # load all avaialble billing and interval data for this account
    def self.fetch_billing_data(service_account)
      self.new(service_account).fetch_billing_data
    end
    
    attr_reader :service_account, :start_time, :options, :web_agent
    
    DEFAULT_OPTIONS = {
      :proxy_port => nil
    }

    def initialize(service_account, options = {})
      @service_account = service_account
      @options = DEFAULT_OPTIONS.merge(options)
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

    # to be subclassed.  returns a hash of three elements:
    # {:start_date => <earliest date inclusive fetched>,
    #  :end_date => <last date exclusive fetched>,
    #  :next_check_date => <date at which next to check>}
    def fetch_billing_data
    end

    # obsolete
    # Each hash in the list of hashes represents a meter reaading.
    # Commit to the MeterReading table if not already present and
    # return a list of MeterReading objects.
    def load_meter_readings(hashes)
      hashes.map do |h|
        r = MeterReading.first_or_create({:service_account => h[:service_account], :date => h[:date]}, h)
        raise RecordError.new("failed to save #{r.inspect}: #{r.errors.full_messages}") unless r.id
      end
    end
    
  end

end
