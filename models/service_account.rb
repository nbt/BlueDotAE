class ServiceAccount
  include DataMapper::Resource
  include DataMapper::Validate

  # Properties
  property :id, Serial
  property :loader_class, String
  property :encrypted_credentials, String, :length => 255
  property :encrypted_credentials_salt, String, :length => 255
  property :encrypted_credentials_iv, String, :length => 255
  property :next_fetch_at, DateTime
  property :created_at, DateTime
  property :updated_at, DateTime

  attr_encrypted :credentials, :key => "a secret key", :marshal => true, :encode => true

  # Associations
  belongs_to :premises
  has n, :meter_readings, :constraint => :destroy

  def self.ready_to_fetch(now = DateTime.now)
    self.all(:next_fetch_at => nil) | self.all(:next_fetch_at.lt => now)
  end

  # Fetch fresh billing data from external sites for those accounts
  # that need it.
  def self.nightly_task
    self.ready_to_fetch.each do |service_account|
      begin
        $stderr.print("ServiceAccount(#{service_account.id}).fetch_billing_data...")
        service_account.fetch_billing_data 
        $stderr.print("success\n")
      rescue ServiceProvider::LoadError => e
        $stderr.print("failure: #{e.message}\n")
      rescue => e
        $stderr.print("error: #{e.message}\n")
        $stderr.print(e.backtrace.join("\n"))
      end
    end
  end

  # Fetch data from utility company and updates the time at which we
  # should next call fetch_billing_data.
  def fetch_billing_data
    self.next_fetch_at = ServiceProvider.const_get(loader_class).fetch_billing_data(self)
    self.save!
    self
  end

end
