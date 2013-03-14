# FactoryGirl does not properly call callbacks.  This model is here
# only for testing purposes so we can see if/when the bug gets fixed.

class TestModel
  include DataMapper::Resource
  property :id, Serial
  property :callback_count, Integer, :default => 0
  property :thing, String

  before :save do
    self.callback_count += 1
    self.geocode if self.attribute_dirty?(:thing)
  end

  def geocode
    puts("thing was #{self.thing}")
    self.thing = "event #{self.callback_count}"
  end

end
