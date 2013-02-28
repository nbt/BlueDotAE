require 'spec_helper'

describe "Premises Model" do
  before(:each) { reset_db }

  it 'can be created' do
    premises = FactoryGirl.create(:premises)
    premises.should_not be_nil
    premises.should be_saved
  end
end
