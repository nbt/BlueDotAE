require 'with_db_cache'

class WebCache
  include DataMapper::Resource
  extend WithDBCache

  # property <name>, <type>
  property :id, Serial
  property :ckey, Object
  property :cvalue, Object
  property :created_at, DateTime
  property :updated_at, DateTime

end
