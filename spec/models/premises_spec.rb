require 'spec_helper'

describe "Premises Model" do
  before(:each) { reset_db }

  let(:premises) { Premises.new }
  it 'can be created' do
    premises.should_not be_nil
  end
end
