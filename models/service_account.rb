class ServiceAccount
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  belongs_to :premises
  has n, :meter_readings, :constraint => :destroy
  property :loader_class, String
  property :credentials, Object
  property :next_fetch_at, DateTime

  def self.ready_to_fetch(now = DateTime.now)
    self.all(:next_fetch_at => nil) | self.all(:next_fetch_at.lt => now)
  end

  # Fetch data from utility company.  Return the time at which we
  # should next call fetch_billing_data.
  def fetch_billing_data
    self.next_fetch_at = ServiceProvider.const_get(loader_class).fetch_billing_data(self)
    self.save!
    self
  end

end
