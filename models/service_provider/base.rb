module ServiceProvider

  class Base
    include Helpers

    # load all avaialble billing and interval data for this account
    def self.fetch_billing_data(service_account)
      self.new(service_account.credentials).fetch_billing_data(service_account.subaccount)
    end
    
    attr_reader :credentials, :start_time, :options, :web_agent
    
    DEFAULT_OPTIONS = {
      :proxy_port => nil
    }

    def initialize(credentials, options = {})
      @credentials = credentials
      @options = DEFAULT_OPTIONS.merge(options)
      # ----
      @web_agent = create_web_agent
    end

    # Test to see if credentials are valid, returning true if user can
    # log in, or a string describing the error otherwise.  Logs out
    # from the remote site unless stay_logged_in is true.
    def probe(stay_logged_in = false)
      begin
        home_page
        logout unless stay_logged_in
        true
      rescue => e
        e.message
      end
    end

    # Return the home page for the user, logging in if needed.  Raises
    # error on any error.
    def home_page
      @home_page ||= login
    end

    # Unconditionally log in and returns home page.  Raises error on
    # any error.
    def login
      raise(StandardError.new("#{self.class}.#{__method__} must be subclassed"))
    end

    # NB: a subclass may explicitly log out, but should call super
    def logout
      @home_page = nil
      @web_agent = create_web_agent # create a fresh agent
    end

    # Return a list of provider-specific account information
    # associated with the logged-in user
    def subaccounts
      raise(StandardError.new("#{self.class}.#{__method__} must be subclassed"))
    end

    # Return the service address of the user account.  Requires
    # the account_info since one user account may span multiple
    # premises.
    def service_address(account_info)
      raise(StandardError.new("#{self.class}.#{__method__} must be subclassed"))
    end

    # Access remote site to fetch and cache raw billing data for the
    # given account.  On success, returns a hash of three elements:
    # {:start_date => <earliest date inclusive fetched>, :end_date =>
    # <last date exclusive fetched>, :next_check_date => <date at
    # which next to check>} On failure, raises an error.
    def fetch_billing_data(subaccount)
      raise(StandardError.new("#{self.class}.#{__method__} must be subclassed"))
    end

    private

    def create_web_agent
      agent = BlueDotBot.new
      agent.set_proxy('localhost', @options[:proxy_port]) if @options[:proxy_port].present?
      # Some sites are particular about the Accept fields in the requests.
      agent.request_headers = {
        'User-Agent' => BlueDotBot::BLUE_DOT_BOT_AGENT,
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language' => 'en-us,en;q=0.5',
        'Accept-Encoding' => 'gzip, deflate',
        'Accept-Charset' => 'ISO-8859-1,utf-8;q=0.7,*;q=0.7'
      }
      agent
    end

=begin
    # ================================================================
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
=end
    
  end

end
