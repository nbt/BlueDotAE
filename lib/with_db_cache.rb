module WithDBCache

  # usage:
  # class MyModel
  #   include DBCache
  #
  #   MyModel.with_db_cache("http://lambda.csail.mit.edu") {|uri|
  #     # called only on cache miss.  returned value is cached.
  #     Net::HTTP.get(URI(uri))
  #   }
  #
  # Assumes MyModel has serialized_key and serialized_value attributes.
  #
  def with_db_cache(akey)
    serialized_key = YAML.dump(akey)
    if (r = self.all(:serialized_key => serialized_key)).count != 0
      YAML.load(r.first.serialized_value)
    else
      yield(akey).tap {|avalue| self.create(:serialized_key => serialized_key, :serialized_value => YAML.dump(avalue))}
    end
  end

end
