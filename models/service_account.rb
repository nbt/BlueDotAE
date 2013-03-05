class ServiceAccount
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id, Serial
  property :service_provider_class, String
  property :encrypted_credentials, String, :length => 255
  property :encrypted_credentials_salt, String, :length => 255
  property :encrypted_credentials_iv, String, :length => 255
  property :start_date, DateTime
  property :end_date, DateTime
  property :next_check_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  attr_encrypted :credentials, :key => "a secret key", :marshal => true, :encode => true

  # Associations
  belongs_to :premises
  has n, :meter_readings, :constraint => :destroy

  def self.ready_to_fetch(now = DateTime.now)
    self.all(:next_check_at => nil) | self.all(:next_check_at.lt => now)
  end

  # Fetch fresh billing data from external sites for those accounts
  # that need it.
  def self.nightly_task
    self.ready_to_fetch.each do |service_account|
      service_account.fetch_billing_data
    end
  end

  def fetch_billing_data
    begin
      $stderr.print("ServiceAccount(#{self.id}).fetch_billing_data...")
      self.fetch_billing_data_aux
      $stderr.print("success\n")
    rescue ServiceProvider::LoadError => e
        $stderr.print("failure: #{e.message}\n")
    rescue => e
      $stderr.print("error: #{e.message}\n")
      $stderr.print(e.backtrace.join("\n"))
    end
    self
  end

  # Fetch data from utility company and updates the time at which we
  # should next call fetch_billing_data.
  def fetch_billing_data_aux
    x = ServiceProvider.const_get(service_provider_class).fetch_billing_data(self)
    if !x[:start_date].nil? && (self.start_date.nil? || (self.start_date > x[:start_date]))
      self.start_date = x[:start_date]
    end
    if !x[:end_date].nil? && (self.end_date.nil? || (self.end_date < x[:end_date]))
      self.end_date = x[:end_date]
    end
    self.next_check_at = x[:next_check_at]
    self.save
    self
  end

end
