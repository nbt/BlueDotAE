require 'spec_helper'

describe "Client Model" do
  before(:each) { reset_db }

  it 'can be created' do
    client = FactoryGirl.create(:client)
    client.should_not be_nil
    client.should be_saved
  end
end
