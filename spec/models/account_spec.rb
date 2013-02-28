require 'spec_helper'

describe "Account Model" do
  before(:each) { reset_db }

  it 'can be created' do
    account = FactoryGirl.create(:account)
    account.should_not be_nil
    account.should be_saved
  end
end
