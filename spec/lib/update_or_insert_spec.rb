require 'spec_helper'
require 'dm-transactions'

# ================================================================
# testing support

class UOITest
  include DataMapper::Resource
  include UpdateOrInsert

  property :id, Serial
  property :f_boolean, Boolean
  property :f_string, String
  property :f_text, Text 
  property :f_float, Float
  property :f_integer, Integer
  property :f_decimal, Decimal
  property :f_datetime, DateTime
  property :f_date, Date
  property :f_time, Time
  property :f_object, Object
  # property :f_binary, Binary

  # these fields get special treatment by DataMapper
  property :type, Discriminator
  property :created_at, DateTime
  property :updated_at, DateTime
end

# DataMapper inserts class type in discriminator field
class UOITestA < UOITest ; end
class UOITestB < UOITest ; end

# Simple factory methods.  You can use the :f_text field to
# discriminate on type (incumbent or candidate) if the test
# calls for it.

def generate_uoi_attributes(n, offset, type)
  n.times.map do |j|
    i = j+offset
    { :f_boolean => i.even?,
      :f_string => "string#{i}",
      :f_text => type,
      :f_float => i.to_f,
      :f_integer => i.to_i,
      :f_decimal => BigDecimal.new(i),
      # Need to understand datetime time zones
      # :f_datetime => DateTime.new(2000, 1, 1) + i
    }
  end
end

# Create un-saved records from a list of attributes
def build_uoi_records(attributes, model=UOITest)
  attributes.map {|h| model.new(h) }
end

# Create saved records from a list of attributes
def create_uoi_records(attributes, model=UOITest)
  attributes.map {|h| model.create(h) }
end

# ================================================================
# tests start here

describe "UpdateOrInsert" do
  before(:all) do
    DataMapper.auto_upgrade!()
    UOITest.finalize
    UOITestA.finalize
    UOITestB.finalize
  end
  after(:all) do
    # TODO: We've created the cov_tests table but not destroyed it,
    # because doing so will make reset_db complain that uoi_tests
    # doesn't exist.  The proper fix is to destroy it AND remove
    # the UOITest class as a descendent of DataMapper (but I don't
    # know how to do that at the moment).
    # adapter = DataMapper.repository(:default).adapter
    # adapter.execute("DROP TABLE #{UOITest.storage_name}")
  end
  before(:each) do
    # reset_db
    UOITest.destroy!
    UOITestA.destroy!
    UOITestB.destroy!
  end

  # ================================================================
  # ================================================================

  describe "argument validation" do
    
    describe 'for candidates' do
      it 'raises error if missing' do
        expect { UOITest.update_or_insert() }.to raise_error(ArgumentError)
      end
      it 'raises error on non-list' do
        expect { UOITest.update_or_insert("string") }.to raise_error(ArgumentError)
      end
      it 'accepts an empty list' do
        expect { UOITest.update_or_insert([]) }.to_not raise_error
      end
    end

    describe 'for conditions' do
      [:all, nil, :none, [], [:dog, "cat"]].each do |valid_arg|
        it "accepts #{valid_arg} as valid" do
          expect { UOITest.update_or_insert([], valid_arg)}.to_not raise_error
        end
      end
      ["string", [:dog, 2]].each do |invalid_arg|
        it "rejects #{invalid_arg} as invalid" do
          expect { UOITest.update_or_insert([], invalid_arg) }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'for :on_update option' do
      [:ignore, :error, :all, [:dog, "cat"]].each do |valid_arg|
        it "accepts #{valid_arg}" do
          expect { UOITest.update_or_insert([], [], :on_update => valid_arg)}.to_not raise_error
        end
      end
      [:teapots, [:dog, 1]].each do |invalid_arg|
        it "rejects #{invalid_arg}" do
          expect { UOITest.update_or_insert([], [], :on_update => invalid_arg)}.to raise_error(ArgumentError)
        end
      end
    end
    
    describe 'for :on_insert option' do
      [:ignore, :error, :all, [:dog, "cat"]].each do |valid_arg|
        it "accepts #{valid_arg}" do
          expect { UOITest.update_or_insert([], [], :on_insert => valid_arg)}.to_not raise_error
        end
      end
      [:teapots, [:dog, 1]].each do |invalid_arg|
        it "accepts #{invalid_arg}" do
          expect { UOITest.update_or_insert([], [], :on_insert => invalid_arg)}.to raise_error(ArgumentError)
        end
      end
    end

    describe 'for :db_adapter option' do
      [:generic, :default, :postgresql, :sqlite, :mysql].each do |name| 
        it "accepts #{name}" do
          expect { UOITest.update_or_insert([], [], :db_adapter => name)}.to_not raise_error
        end
      end
      [:teapots, 1, []].each do |arg|
        it "rejects #{arg} as unrecognized" do
          expect { UOITest.update_or_insert([], [], :db_adapter => arg)}.to raise_error(ArgumentError)
        end
      end
    end

    describe 'for unrecognized option' do
      it 'raises error' do
        expect { UOITest.update_or_insert([], [], :teapots => :dancing)}.to raise_error(ArgumentError)
      end
    end

  end                           # describe "argument validation" do

  # ================================================================
  # ================================================================

  describe 'update_or_insert' do
    before(:each) do
      @n_incumbents = 10
      @incumbent_attributes = generate_uoi_attributes(@n_incumbents, 0, "incumbent")
      @incumbent_records = create_uoi_records(@incumbent_attributes)
      
      @n_candidates = 10
      @candidate_attributes = generate_uoi_attributes(@n_candidates, @n_incumbents / 2, "candidate")
      @candidate_records = build_uoi_records(@candidate_attributes)
    end

    it 'conditions = :none, :on_update => :all, :on_insert => :all' do
      
      # with conditions = :none, candidates are inserted whether or
      # not there is an identical incumbent record.  So updates are
      # never performed.  In this case, half of the inserted records
      # should be identical to the incumbents except for the "f_text"
      # column.

      UOITest.count.should == @n_incumbents
      UOITest.update_or_insert(@candidate_records, 
                               :none, 
                               :on_update => :all, 
                               :on_insert => :all)
      UOITest.count.should == @n_incumbents + @n_candidates

      # check values: both incumbents and candidates should be present
      @incumbent_attributes.each do |incumbent|
        found = UOITest.all(:f_integer => incumbent[:f_integer], :f_text => incumbent[:f_text])
        found.count.should == 1
        incumbent.each_pair {|k,v| found.first[k].should == v}
      end
      @candidate_attributes.each do |candidate|
        found = UOITest.all(:f_integer => candidate[:f_integer], :f_text => candidate[:f_text])
        found.count.should == 1
        candidate.each_pair {|k,v| found.first[k].should == v}
      end
    end
    
    
    it 'conditions = :all, :on_update => :all, :on_insert => :all' do
        
      # with conditions = :all, none of the incumbents will match
      # with the candidates (in this case), so this behaves as an
      # insert-only operation.

      # TODO: is there EVER a case that conditions = :all will do an
      # update?  Is conditions = :all useful?

      # Commentary: if a candidate is identical to an incumbent, then
      # it makes no sense to perform the update: the record won't be
      # changed (except perhaps for :updated_at).  If the candidate
      # differs from the incumbent, then it will perform an insert.

      UOITest.count.should == @n_incumbents
      UOITest.update_or_insert(@candidate_records, 
                               :all, 
                               :on_update => :all,
                               :on_insert => :all)
      UOITest.count.should == @n_incumbents + @n_candidates

      # check values: both incumbents and candidates should be present
      @incumbent_attributes.each do |incumbent|
        found = UOITest.all(:f_integer => incumbent[:f_integer], :f_text => incumbent[:f_text])
        found.count.should == 1
        incumbent.each_pair {|k,v| found.first[k].should == v}
      end
      @candidate_attributes.each do |candidate|
        found = UOITest.all(:f_integer => candidate[:f_integer], :f_text => candidate[:f_text])
        found.count.should == 1
        candidate.each_pair {|k,v| found.first[k].should == v}
      end
      
    end
    
    it 'conditions = [:f_integer], :on_update => :all, :on_insert => :all' do
        
      # with conditions = [:f_integer], half of the incumbent records
      # will match and be subject to updating.

      UOITest.count.should == @n_incumbents
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :all,
                               :on_insert => :all)
      UOITest.count.should == @n_incumbents + (@n_candidates / 2)

      # check values: incumbents should be updated by candidates
      @incumbent_attributes.each do |incumbent|
        found = UOITest.all(:f_integer => incumbent[:f_integer], :f_text => incumbent[:f_text])
        if (incumbent[:f_integer] < @n_incumbents / 2)
          found.count.should == 1
          incumbent.each_pair {|k,v| found.first[k].should == v}
        else
          found.count.should == 0
        end
      end
      @candidate_attributes.each do |candidate|
        found = UOITest.all(:f_integer => candidate[:f_integer], :f_text => candidate[:f_text])
        found.count.should == 1
        candidate.each_pair {|k,v| found.first[k].should == v}
      end
      
    end
    
    it 'conditions = [:f_integer], :on_update => :ignore, :on_insert => :all' do
        
      # with conditions = [:f_integer], half of the incumbent records
      # match are subject to updating.  But :on_update => :ignore
      # inhibits the updates.

      UOITest.count.should == @n_incumbents
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :ignore,
                               :on_insert => :all)
      UOITest.count.should == @n_incumbents + (@n_candidates / 2)
      # check values: incumbents should be unmodified
      @incumbent_attributes.each do |incumbent|
        found = UOITest.all(:f_integer => incumbent[:f_integer], :f_text => incumbent[:f_text])
        found.count.should == 1
        incumbent.each_pair {|k,v| found.first[k].should == v}
      end
      @candidate_attributes.each do |candidate|
        found = UOITest.all(:f_integer => candidate[:f_integer], :f_text => candidate[:f_text])
        if (candidate[:f_integer] < @n_incumbents)
          found.count.should == 0
        else
          found.count.should == 1
          candidate.each_pair {|k,v| found.first[k].should == v}
        end
      end
      
    end
    
    it 'conditions = [:f_integer], :on_update => :error, :on_insert => :all' do
        
      # with conditions = [:f_integer], half of the incumbent records
      # match are subject to updating.  With :on_update => :error,
      # it should raise an error

      UOITest.count.should == @n_incumbents
      expect {
        UOITest.update_or_insert(@candidate_records, 
                                 [:f_integer], 
                                 :on_update => :error,
                                 :on_insert => :all)
      }.to raise_error(UpdateOrInsert::UpdateError)
      
    end
    
    it 'conditions = [:f_integer], :on_update => :all, :on_insert => :ignore' do
        
      # with conditions = [:f_integer], half of the incumbent records
      # match are subject to updating.  With :on_insert => :ignore,
      # no new records are inserted, only existing records are updated

      UOITest.count.should == @n_incumbents
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :all,
                               :on_insert => :ignore)
      UOITest.count.should == @n_incumbents
      # check values: half the incumbents should be updated, no
      # new records should be created.
      @incumbent_attributes.each do |incumbent|
        found = UOITest.all(:f_integer => incumbent[:f_integer], :f_text => incumbent[:f_text])
        if (incumbent[:f_integer] < @n_incumbents/2)
          found.count.should == 1
          incumbent.each_pair {|k,v| found.first[k].should == v}
        else
          found.count.should == 0
        end
      end
      @candidate_attributes.each do |candidate|
        found = UOITest.all(:f_integer => candidate[:f_integer], :f_text => candidate[:f_text])
        if (candidate[:f_integer] < @n_incumbents)
          found.count.should == 1
          candidate.each_pair {|k,v| found.first[k].should == v}
        else
          found.count.should == 0
        end
      end
      
    end
    
    it 'conditions = [:f_integer], :on_update => :all, :on_insert => :error' do
        
      # with conditions = [:f_integer], half of the incumbent records
      # match are subject to updating.  With :on_insert => :error,
      # it should raise an error trying to insert.

      UOITest.count.should == @n_incumbents
      expect {
        UOITest.update_or_insert(@candidate_records, 
                                 [:f_integer], 
                                 :on_update => :all,
                                 :on_insert => :error)
      }.to raise_error(UpdateOrInsert::InsertError)
      
    end
    
    it 'conditions = [:f_integer], :on_update => [:f_string], :on_insert => :all' do
      # modify the @candidate_attributes so we can see the difference.
      @candidate_attributes.each {|a| a[:f_string] = "strange#{a[:f_integer]}"}
      @candidate_records = build_uoi_records(@candidate_attributes)
        
      # with conditions = [:f_integer], half of the incumbent records
      # will match and be subject to updating.  But we're only
      # updating the :f_string field, and not the :f_text field

      UOITest.count.should == @n_incumbents
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => [:f_string],
                               :on_insert => :all)
      UOITest.count.should == @n_incumbents + (@n_candidates / 2)

      # check values
      @incumbent_attributes.each do |incumbent|
        found = UOITest.all(:f_integer => incumbent[:f_integer], :f_text => incumbent[:f_text])
        found.count.should == 1
        if (incumbent[:f_integer] < @n_incumbents/2)
          incumbent.each_pair {|k,v| found.first[k].should == v}
        else
          incumbent.reject {|k, v| k==:f_string}.each_pair {|k,v| found.first[k].should == v}
          found.first[:f_string].should =~ /\Astrange/
        end
      end
      @candidate_attributes.each do |candidate|
        found = UOITest.all(:f_integer => candidate[:f_integer], :f_text => candidate[:f_text])
        if (candidate[:f_integer] < @n_incumbents)
          found.count.should == 0
        else
          found.count.should == 1
          candidate.each_pair {|k,v| found.first[k].should == v}
        end
      end
      
    end
    
    it 'conditions = [:f_integer], :on_update => :all, :on_insert => [:f_integer, :f_string]' do
      # modify the @candidate_attributes so we can see the difference.
      @candidate_attributes.each {|a| a[:f_string] = "strange#{a[:f_integer]}"}
      @candidate_records = build_uoi_records(@candidate_attributes)
        
      # with conditions = [:f_integer], half of the incumbent records
      # will match and be subject to updating.  Updates are processed
      # normally, but with the :on_insert => [:f_string], only the
      # f_string column is populated in an insert.

      UOITest.count.should == @n_incumbents
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :all,
                               :on_insert => [:f_integer, :f_string])
      UOITest.count.should == @n_incumbents + (@n_candidates / 2)
      # check values: half of the incumbents should be updated,
      # the newly inserted candidates should only have :f_integer and
      # f_string fields populated
      @incumbent_attributes.each do |incumbent|
        found = UOITest.all(:f_integer => incumbent[:f_integer], :f_text => incumbent[:f_text])
        if (incumbent[:f_integer] < @n_incumbents/2)
          found.count.should == 1
          incumbent.each_pair {|k,v| found.first[k].should == v}
        else
          found.count.should == 0
        end
      end
      @candidate_attributes.each do |candidate|
        found = UOITest.all(:f_integer => candidate[:f_integer])
        found.count.should == 1
        candidate.each_pair do |k, v|
          if (candidate[:f_integer] < @n_incumbents)
            # updated row: all fields populated
            found.first[k].should == v
          elsif [:f_integer, :f_string].member?(k)
            # inserted row: only :f_integer and :f_string populated
            found.first[k].should == v
          else
            # inserted row: other columns are nil
            found.first[k].should be_nil
          end
        end
      end
      
    end
    
  end                           # describe 'update_or_insert' do

  describe 'benchmarking' do

    before(:each) do
      @n_incumbents = 1000
      @incumbent_attributes = generate_uoi_attributes(@n_incumbents, 0, "incumbent")
      @incumbent_records = create_uoi_records(@incumbent_attributes)
      
      @n_candidates = 1000
      @candidate_attributes = generate_uoi_attributes(@n_candidates, @n_incumbents / 2, "candidate")
      @candidate_records = build_uoi_records(@candidate_attributes)
    end

    def setup
      reset_db
      @incumbent_attributes = generate_uoi_attributes(@n_incumbents, 0, "incumbent")
      @incumbent_records = create_uoi_records(@incumbent_attributes)
      @candidate_attributes = generate_uoi_attributes(@n_candidates, @n_incumbents / 2, "candidate")
      @candidate_records = build_uoi_records(@candidate_attributes)
    end

    it 'should run faster within a transaction than not' do

      setup
      t0s = DateTime.now
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :all,
                               :on_insert => :all,
                               :within_transaction => false)
      t0e = DateTime.now

      setup
      t1s = DateTime.now
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :all,
                               :on_insert => :all,
                               :within_transaction => false)
      t1e = DateTime.now
      UOITest.count(:f_text => "incumbent").should == @n_incumbents / 2
      UOITest.count(:f_text => "candidate").should == @n_candidates

      setup
      t2s = DateTime.now
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :all,
                               :on_insert => :all,
                               :within_transaction => true)
      t2e = DateTime.now

      setup
      t3s = DateTime.now
      UOITest.update_or_insert(@candidate_records, 
                               [:f_integer], 
                               :on_update => :all,
                               :on_insert => :all,
                               :within_transaction => true)
      t3e = DateTime.now
      UOITest.count(:f_text => "incumbent").should == @n_incumbents / 2
      UOITest.count(:f_text => "candidate").should == @n_candidates

      without_s = (t1e-t1s) * 3600.0 * 24
      with_s = (t3e-t3s) * 3600.0 * 24

      $stderr.puts("\nwithin transactions: #{with_s} s, without transactions: #{without_s} s")
      with_s.should < without_s
      
    end

  end                           # describe 'benchmarking' do
  
end                             # describe "UpdateOrInsert" do

