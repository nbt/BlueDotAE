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

    it 'should return ServiceAccount records whose next_fetch_at is nil or in the past' do
      past = DateTime.new(2010, 1, 1)
      now = DateTime.new(2010, 1, 2)
      future = DateTime.new(2010, 1, 3)

      premises = FactoryGirl.create(:premises)
      sa = FactoryGirl.create(:service_account, :next_fetch_at => past, :premises => premises)
      sb = FactoryGirl.create(:service_account, :next_fetch_at => future, :premises => premises)
      sc = FactoryGirl.create(:service_account, :next_fetch_at => nil, :premises => premises)

      ServiceAccount.ready_to_fetch(now).should =~ [sa, sc]
    end

  end

  describe "fetch_billing_data" do
    before(:each) do
    end
    
    it 'should call the underlying loader class' do
      service_account = FactoryGirl.create(:service_account, :loader_class => "LoaderBase")
      ServiceProvider::LoaderBase.should_receive(:fetch_billing_data).with(service_account)
      expect {service_account.fetch_billing_data}.to_not raise_error
    end

    it 'should set next_fetch_at to value returned by fetch_billing_data' do
      date = DateTime.new(2012, 1, 1)
      service_account = FactoryGirl.create(:service_account, :loader_class => "LoaderBase")
      ServiceProvider::LoaderBase.should_receive(:fetch_billing_data) { date }
      service_account.fetch_billing_data
      service_account.next_fetch_at.should == date
    end

  end


  describe 'nightly task' do
    
    it 'calls fetch_billing_data' do
      FactoryGirl.create(:service_account, 
                         :loader_class => "SDGELoader",
                         :credentials => {
                           "user_id" => "ChrisWrightFamily", 
                           "password" => "SDGEolus1402",
                           "meter_id" => "05219047"})
      ServiceAccount.any_instance.should_receive(:fetch_billing_data)
      ServiceAccount.nightly_task
    end

    it 'does nothing if all service_accounts are up to date' do
      FactoryGirl.create(:service_account, 
                         :next_fetch_at => DateTime.now + 1 # tomorrow
                         )
      ServiceAccount.any_instance.should_not_receive(:fetch_billing_data)
      ServiceAccount.nightly_task
    end

    it 'reports success with valid account' do
      FactoryGirl.create(:service_account, 
                         :loader_class => "SDGELoader",
                         :credentials => {
                           "user_id" => "ChrisWrightFamily", 
                           "password" => "SDGEolus1402",
                           "meter_id" => "05219047"})
      VCR.use_cassette("ServiceAccount_nightly_task_reports_success_with_valid_account", :tag => :with_time_frozen) do
        begin
          logging_data = with_output_captured { ServiceAccount.nightly_task }
          logging_data[:stderr].should =~ /success/
        ensure
          Timecop.return
        end
      end
    end

    it 'reports failure with invalid account' do
      FactoryGirl.create(:service_account, 
                         :loader_class => "SDGELoader",
                         :credentials => {
                           "user_id" => "ChrisWrightFamily", 
                           "password" => "i_am_not_the_password",
                           "meter_id" => "05219047"})
      VCR.use_cassette("ServiceAccount_reports_failure_with_invalid_account", :tag => :with_time_frozen) do
        begin
          logging_data = with_output_captured { ServiceAccount.nightly_task }
          logging_data[:stderr].should =~ /failure/
        ensure
          Timecop.return
        end
      end
    end

    it 'reports error with unknown loader' do
      FactoryGirl.create(:service_account, 
                         :loader_class => "NonExistentLoader",
                         :credentials => {})
      logging_data = with_output_captured { ServiceAccount.nightly_task }
      logging_data[:stderr].should =~ /error/
    end

  end

end
