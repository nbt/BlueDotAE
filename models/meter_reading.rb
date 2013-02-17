class MeterReading
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  belongs_to :service_account
  property :date, DateTime
  property :duration_s, Float
  property :cost, Float
  property :quantity, Float

end
