require 'spec_helper'

class KVTest
  include DataMapper::Resource
  include ActsAsKeyValueStore
  acts_as_key_value_store

  property :id, Serial
  property :ckey, Object
  property :cvalue, Object
  property :aux, String

end

describe ActsAsKeyValueStore do
  before(:all) do
    DataMapper.auto_upgrade!()
    KVTest.finalize
  end
  after(:all) do
    # TODO: We've created the kv_tests table but not destroyed it,
    # because doing so will make reset_db complain that kv_tests
    # doesn't exist.  The proper fix is to destroy it AND remove
    # the KVTest class as a descendent of DataMapper (but I don't
    # know how to do that at the moment).
    # adapter = DataMapper.repository(:default).adapter
    # adapter.execute("DROP TABLE #{KVTest.storage_name}")
  end

  before(:each) do
    KVTest.destroy!
  end

  it 'can be created' do
    record = KVTest.create
    record.should be_saved
    KVTest.count.should == 1
  end

  describe 'generate_key' do

    it 'converts one arg' do
      KVTest.generate_key(1).should be_instance_of(String)
    end

    it 'converts two args' do
      KVTest.generate_key(1, :b).should be_instance_of(String)
    end
      
  end

  describe 'put' do

    it 'puts' do
      KVTest.count.should == 0
      KVTest.put("asdf", "moo")
      KVTest.count.should == 1
    end

    it 'without a body creates record' do
      KVTest.count.should == 0
      expect { @record = KVTest.put(KVTest.generate_key(1, :b), "moo") }.to_not raise_error
      KVTest.count.should == 1
      @record.should be_instance_of(KVTest)
      @record.should be_saved
      @record.should_not be_dirty
      @record.aux.should be_nil
    end

    it 'with a body creates record with other fields filled in' do
      KVTest.count.should == 0
      expect { 
        @record = KVTest.put(KVTest.generate_key(1, :b), "moo") { |r|
          r.aux = "baa"
        }
      }.to_not raise_error
      KVTest.count.should == 1
      @record.should be_saved
      @record.should_not be_dirty
      @record.aux.should == 'baa'
    end

  end

  describe 'ref' do
    before(:each) do
      @record = KVTest.put(KVTest.generate_key(1, :b), "moo")
    end

    it 'should find existing record' do
      KVTest.ref(KVTest.generate_key(1, :b)).should == @record
    end

    it 'should not find non-existent record' do
      KVTest.ref(KVTest.generate_key(2, :c)).should == nil
    end
    
  end

  describe 'has_key?' do
    before(:each) do
      @record = KVTest.put(KVTest.generate_key(1, :b), "moo")
    end

    it 'should find existing record' do
      KVTest.has_key?(KVTest.generate_key(1, :b)).should be_true
    end

    it 'should not find non-existent record' do
      KVTest.has_key?(KVTest.generate_key(2, :c)).should be_false
    end

  end

  describe 'get' do
    before(:each) do
      @record = KVTest.put(KVTest.generate_key(1, :b), "moo")
    end

    it 'should find existing record' do
      KVTest.get(KVTest.generate_key(1, :b)).should == "moo"
    end

    it 'should not find non-existent record' do
      KVTest.get(KVTest.generate_key(2, :c)).should == nil
    end

  end

  describe 'keys' do
    before(:each) do
      @keys = [KVTest.generate_key(1, :b), KVTest.generate_key(2, :c)]
      @keys.map {|k| KVTest.put(k, k.reverse) }
    end

    it 'should find keys' do
      KVTest.keys.should =~ @keys
    end

  end

  describe 'values' do
    before(:each) do
      @values = [KVTest.generate_key(1, :b), KVTest.generate_key(2, :c)]
      @values.map {|v| KVTest.put(v.reverse, v)}
    end

    it 'should find values' do
      KVTest.values.should =~ @values
    end

  end

  describe 'fetch' do
    before(:each) do
      @record = KVTest.put(KVTest.generate_key(1, :b), "moo")
    end
    
    it 'should not execute block when key exists' do
      expect { KVTest.fetch(1, :b) {
          raise StandardError.new("should not execute block")
        }
      }.to_not raise_error
    end

    it 'should return the correct value when key exists' do
      KVTest.fetch(1, :b).should == "moo"
    end

    it 'should execute block when key does not exist' do
      expect { KVTest.fetch(2, :c) {
          raise StandardError.new("should not execute block")
        }
      }.to raise_error(StandardError)
    end
      
    it 'should pass identical arguments to block when key does not exist' do
      KVTest.fetch(2, :c) {|a, b|
        @a = a
        @b = b
        "woof"
      }
      @a.should == 2
      @b.should == :c
      KVTest.get(KVTest.generate_key(2, :c)).should == "woof"
    end

  end

end
