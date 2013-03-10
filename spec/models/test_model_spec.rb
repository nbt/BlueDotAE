require 'spec_helper'

describe "TestModel Model" do
  it 'calls before :save using TestModel.create' do
    test_model = TestModel.create
    test_model.callback_count.should == 1
  end
  it 'calls before :save using FactoryGirl.create' do
    pending 'FactoryGirl does not play nice with DataMapper'
    test_model = FactoryGirl.create(:test_model)
    test_model.callback_count.should == 1
  end
end
