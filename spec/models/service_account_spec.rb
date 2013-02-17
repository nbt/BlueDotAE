require 'spec_helper'

describe "ServiceAccount Model" do
  let(:service_account) { ServiceAccount.new }
  it 'can be created' do
    service_account.should_not be_nil
  end
end
