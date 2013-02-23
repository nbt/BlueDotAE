require 'acts_as_key_value_store'

module WebCaches

  module SDGE

    class BillSummary
      include DataMapper::Resource
      include ActsAsKeyValueStore
      acts_as_key_value_store
      
      # property <name>, <type>
      property :id, Serial
      property :ckey, Object
      property :cvalue, Object
      property :created_at, DateTime
      property :updated_at, DateTime
      
    end

  end

end
