require 'spec_helper'

describe "Client Model" do
  before(:each) { reset_db }

  let(:client) { Client.new }
  it 'can be created' do
    client.should_not be_nil
  end
end
