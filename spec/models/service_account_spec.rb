require 'spec_helper'
require 'vcr_helper'

FULL_EXAMPLE = "ServiceAccount fetch_billing_data ordinary case"

describe "ServiceAccount Model" do
  before(:each) { reset_db }

  it 'can be created' do
    service_account = FactoryGirl.create(:service_account)
    service_account.should_not be_nil
    service_account.should be_saved
  end

  it 'saves to db' do
    ServiceAccount.count.should == 0
    service_account = FactoryGirl.create(:service_account)
    ServiceAccount.count.should == 1
  end

  describe "credentials" do

    it "should not store unencrypted credentials in the db" do
      credentials = {:this_is => :secret}
      FactoryGirl.create(:service_account, :credentials => credentials)
      service_account = ServiceAccount.first
      service_account.attributes.should_not have_key(:credentials)
    end

    it "should store and retreive credentials" do
      credentials = {:this_is => :secret}
      FactoryGirl.create(:service_account, :credentials => credentials)
      service_account = ServiceAccount.first
      service_account.credentials.should == credentials
    end

  end

  describe "ready_to_fetch"  do
    
    it 'should return empty list with no ServiceAccount records' do
      ServiceAccount.ready_to_fetch.should == []
    end

    it 'should return ServiceAccount records whose next_check_at is nil or in the past' do
      past = DateTime.new(2010, 1, 1)
      now = DateTime.new(2010, 1, 2)
      future = DateTime.new(2010, 1, 3)

      premises = FactoryGirl.create(:premises)
      sa = FactoryGirl.create(:service_account, :next_check_at => past, :premises => premises)
      sb = FactoryGirl.create(:service_account, :next_check_at => future, :premises => premises)
      sc = FactoryGirl.create(:service_account, :next_check_at => nil, :premises => premises)

      ServiceAccount.ready_to_fetch(now).should =~ [sa, sc]
    end

  end

  describe "fetch_billing_data" do
    before(:each) do
    end
    
    it 'should set next_check_at to value returned by fetch_billing_data' do
      start_date = DateTime.new(2012, 1, 1)
      end_date = DateTime.new(2012, 1, 2)
      next_check_at = DateTime.new(2012, 1, 3)

      date = DateTime.new(2012, 1, 1)
      service_account = FactoryGirl.create(:service_account, :service_provider_class => "Base")
      ServiceProvider::Base.should_receive(:fetch_billing_data) { 
        { :start_date => start_date,
          :end_date => end_date,
          :next_check_at => next_check_at }
      }
      service_account.fetch_billing_data
      service_account.start_date.should == start_date
      service_account.end_date.should == end_date
      service_account.next_check_at.should == next_check_at
    end

  end


  describe 'nightly task' do
    
    it 'calls fetch_billing_data' do
      FactoryGirl.create(:service_account)
      ServiceAccount.any_instance.should_receive(:fetch_billing_data)
      ServiceAccount.nightly_task
    end

    it 'does nothing if all service_accounts are up to date' do
      FactoryGirl.create(:service_account, 
                         :next_check_at => DateTime.now + 1 # tomorrow
                         )
      ServiceAccount.any_instance.should_not_receive(:fetch_billing_data)
      ServiceAccount.nightly_task
    end

    it 'reports success with valid account and subaccount' do
      FactoryGirl.create(:service_account, 
                         :service_provider_class => "Test",
                         :credentials => ServiceProvider::Test::VALID_CREDENTIALS,
                         :subaccount => ServiceProvider::Test::SUBACCOUNTS.first
                         )
      logging_data = with_output_captured { ServiceAccount.nightly_task }
      logging_data[:stderr].should =~ /success/
    end

    it 'reports failure with valid account and invalid subaccount' do
      FactoryGirl.create(:service_account, 
                         :service_provider_class => "Test",
                         :credentials => ServiceProvider::Test::VALID_CREDENTIALS,
                         :subaccount => :not_your_grandmothers_subaccount
                         )
      logging_data = with_output_captured { ServiceAccount.nightly_task }
      logging_data[:stderr].should =~ /failure/
    end

    it 'reports failure with invalid account' do
      FactoryGirl.create(:service_account, 
                         :service_provider_class => "Test",
                         :credentials => { :foo => :bar },
                         :subaccount => ServiceProvider::Test::SUBACCOUNTS.first
                         )
      logging_data = with_output_captured { ServiceAccount.nightly_task }
      logging_data[:stderr].should =~ /failure/
    end

    it 'reports error with unknown service_provider' do
      FactoryGirl.create(:service_account, 
                         :service_provider_class => "NonExistentServiceProvider",
                         :credentials => {})
      logging_data = with_output_captured { ServiceAccount.nightly_task }
      logging_data[:stderr].should =~ /error/
    end

  end

end
