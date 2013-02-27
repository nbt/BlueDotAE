require 'spec_helper'

describe "Account Model" do
  before(:each) { reset_db }

  let(:account) { Account.new }
  it 'can be created' do
    account.should_not be_nil
  end
end
