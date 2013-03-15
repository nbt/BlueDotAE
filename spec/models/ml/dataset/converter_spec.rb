require 'spec_helper'

describe 'ML::Dataset::Converter' do
  before(:each) do
    @label_column = :price
    @feature_columns = [:color, :size]
    @training_data = [{:color => :red, :size => 10.0, :price => 20.0},
                      {:color => :blue, :size => 20.1, :price => 20.2}]
  end

  describe 'initializer' do

    it 'does not error' do
      expect {
        converter = ML::Dataset::Converter.new(@training_data, 
                                               @label_column, 
                                               @feature_columns)
        converter.should be_instance_of(ML::Dataset::Converter)
      }.to_not raise_error
    end

    it 'creates a converter' do
      ML::Dataset::Converter.new(@training_data, 
                                 @label_column, 
                                 @feature_columns).should be_instance_of(ML::Dataset::Converter)
    end

  end

  describe 'create_dataset' do
    before(:each) do
      @converter = ML::Dataset::Converter.new(@training_data, 
                                              @label_column, 
                                              @feature_columns)
    end

    it 'succeeds on empty training data' do
      expect {
        dataset = @converter.create_dataset([])
        dataset.should be_instance_of(ML::Dataset::Dataset)
      }.to_not raise_error
    end

    it 'succeeds on training data' do
      expect {
        dataset = @converter.create_dataset(@training_data)
        dataset.should be_instance_of(ML::Dataset::Dataset)
      }.to_not raise_error
    end

    it 'succeeds with testing data' do
      testing_data = 
        [{:color => :red, :size => 100.0, :price => 200.0},
         {:color => :blue, :size => 200.1, :price => 200.2},
         {:color => :red, :size => 300.1, :price => 300.2}]
      expect {
        dataset = @converter.create_dataset(testing_data)
        dataset.should be_instance_of(ML::Dataset::Dataset)
        dataset.length.should == testing_data.length
      }.to_not raise_error
    end
      
    it 'succeeds with unrecognized categeory data' do
      testing_data = 
        [{:color => :red, :size => 100.0, :price => 200.0},
         {:color => :blue, :size => 200.1, :price => 200.2},
         {:color => :aubergine, :size => 300.1, :price => 300.2}]
      dataset = @converter.create_dataset(testing_data)
      dataset.should be_instance_of(ML::Dataset::Dataset)
      dataset.length.should == testing_data.length
      
      dataset[0].label.should == {"price" => 200.0}
      dataset[0].features.should == {"color=red" => 1.0, "color=blue" => 0.0, "size" => 100.0}
      
      dataset[1].label.should == {"price" => 200.2}
      dataset[1].features.should == {"color=red" => 0.0, "color=blue" => 1.0, "size" => 200.1}
      
      dataset[2].label.should == {"price" => 300.2}
      dataset[2].features.should == {"color=red" => 0.0, "color=blue" => 0.0, "size" => 300.1}
    end
      
    it 'with is_testing true inhibits label data' do
      testing_data = 
        [{:color => :red, :size => 100.0, :price => 200.0},
         {:color => :blue, :size => 200.1, :price => 200.2},
         {:color => :aubergine, :size => 300.1, :price => 300.2}]
      dataset = @converter.create_dataset(testing_data, true)
      dataset.should be_instance_of(ML::Dataset::Dataset)
      dataset.length.should == testing_data.length
      
      dataset[0].label.should == {"price" => nil}
      dataset[0].features.should == {"color=red" => 1.0, "color=blue" => 0.0, "size" => 100.0}
      
      dataset[1].label.should == {"price" => nil}
      dataset[1].features.should == {"color=red" => 0.0, "color=blue" => 1.0, "size" => 200.1}
      
      dataset[2].label.should == {"price" => nil}
      dataset[2].features.should == {"color=red" => 0.0, "color=blue" => 0.0, "size" => 300.1}
    end
      
  end

  describe 'headers' do
    before(:each) do
      @converter = ML::Dataset::Converter.new(@training_data, 
                                              @label_column, 
                                              @feature_columns)
    end

    it 'returns headers' do
      testing_data = 
        [{:color => :red, :size => 100.0, :price => 200.0},
         {:color => :blue, :size => 200.1, :price => 200.2},
         {:color => :aubergine, :size => 300.1, :price => 300.2}]

      @converter.headers.should == ["price", "color=red", "color=blue", "size"]
    end
      
  end

end
