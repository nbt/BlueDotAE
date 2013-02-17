class ServiceAccount
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  has n, :meter_readings
  property :loader_class, String
  property :access_credentials, String

  def etl_meter_readings(start_time)
    ServiceProvider.const_get(loader_class).etl_meter_readings(self, start_time)
  end

  def credentials
    @credentials ||= YAML.load(self.access_credentials)
  end

  def credentials=(c)
    @credentials = nil
    self.access_credentials = YAML.dump(c)
  end

end
