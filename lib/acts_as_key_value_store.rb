module ActsAsKeyValueStore

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def acts_as_key_value_store
      class_eval <<-EOV
        include ActsAsKeyValueStore::InstanceMethods

        def self.generate_key(*args)
          args.map {|a| a.to_s}.join("_")
        end

        def self.ref(key)
          self.all(:ckey => key).first
        end
        
        def self.has_key?(key)
          self.all(:ckey => key).count > 0
        end
        
        def self.get(key)
          (r = ref(key)) && r.cvalue
        end
        
        def self.put(key, value, &body)
          first_or_new({:ckey => key}, {:cvalue => value}).tap {|r|
            yield(r) if block_given?
            r.save
          }
        end

        def self.keys
          self.all(:fields => [:ckey]).map {|r| r.ckey}
        end
        
        def self.values
          self.all(:fields => [:cvalue]).map {|r| r.cvalue}
        end
        
        def self.fetch(*args, &block)
          key = self.generate_key(*args)
          if (r = ref(key))
            r.cvalue
          else
            yield(*args).tap {|value| self.create(:ckey => key, :cvalue => value)}
          end
        end
        
        EOV
    end
  end  
    
  module InstanceMethods

  end

end
