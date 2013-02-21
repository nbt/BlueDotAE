class ServiceAccount
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  has n, :meter_readings
  property :loader_class, String
  property :credentials, Object

  # ServiceAccount#fetch_billing_data accesses the external utility
  # company site in order to fetch any available billing data for
  # this service_account and save it its raw form in the WebCache
  # table.  
  #
  # This method is designed to be called as a delayed job in a
  # separate process.  The heavy lifting is done by a utility-specific
  # class (loader_class), which itself will normally schedule
  # additional tasks and log results in a log file
  #
  def fetch_billing_data_and_reschedule
    run_at = fetch_billing_data
    self.delay(:run_at => run_at).fetch_billing_data if run_at
  end
    
  def fetch_billing_data
    ServiceProvider.const_get(loader_class).fetch_billing_data(self)
  end

end
