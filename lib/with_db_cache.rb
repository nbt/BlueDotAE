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
  # Assumes MyModel has ckey and cvalue attributes.
  #
  def with_db_cache(key)
    if (r = self.all(:ckey => key)).count != 0
      r.first.cvalue
    else
      yield(key).tap {|value| self.create(:ckey => key, :cvalue => value)}
    end
  end

end
