class Client
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  has n, :premises, 'Premises', :constraint => :destroy

end
