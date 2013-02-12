require 'with_db_cache'

class WebCache
  include DataMapper::Resource
  extend WithDBCache

  # property <name>, <type>
  property :id, Serial
  property :serialized_key, Text
  property :serialized_value, Text
  property :created_at, DateTime
  property :updated_at, DateTime

end
