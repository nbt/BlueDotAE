require 'spec_helper'
require 'vcr_helper'

FULL_EXAMPLE = "ServiceAccount fetch_billing_data ordinary case"

describe "ServiceAccount Model" do
  before(:each) do
    ServiceAccount.destroy!
    # TODO: Migrate utility-specific tests into separate modules
    WebCaches::SDGE::BillSummary.destroy!
    WebCaches::SDGE::BillDetail.destroy!
    WebCaches::SDGE::MeterReading.destroy!
  end

  let(:service_account) { ServiceAccount.new }
  it 'can be created' do
    service_account.should_not be_nil
  end

  describe "ready_to_fetch"  do
    
    it 'should return empty list with no ServiceAccount records' do
      ServiceAccount.ready_to_fetch.should == []
    end

    it 'should return ServiceAccount records whose next_fetch_at is nil or in the past' do
      past = DateTime.new(2010, 1, 1)
      now = DateTime.new(2010, 1, 2)
      future = DateTime.new(2010, 1, 3)

      sa = ServiceAccount.create(:next_fetch_at => past)
      sb = ServiceAccount.create(:next_fetch_at => future)
      sc = ServiceAccount.create(:next_fetch_at => nil)

      ServiceAccount.ready_to_fetch(now).should =~ [sa, sc]
    end

  end

  describe "fetch_billing_data" do
    before(:each) do
    end
    
    it 'should call the underlying loader class' do
      service_account = ServiceAccount.create(:loader_class => "LoaderBase")
      ServiceProvider::LoaderBase.should_receive(:fetch_billing_data).with(service_account)
      expect {service_account.fetch_billing_data}.to_not raise_error
    end

    it 'should set next_fetch_at to value returned by fetch_billing_data' do
      date = DateTime.new(2012, 1, 1)
      service_account = ServiceAccount.create(:loader_class => "LoaderBase")
      ServiceProvider::LoaderBase.should_receive(:fetch_billing_data) { date }
      service_account.fetch_billing_data
      service_account.next_fetch_at.should == date
    end

    # TODO: migrate all service_provider specific tests into the
    # service_provider/ subdirectory
    describe "from sdge" do
      before(:each) do
        @sdge_account = ServiceAccount.create(:loader_class => "SDGELoader",
                                              :credentials => {
                                                "user_id" => "ChrisWrightFamily", 
                                                "password" => "SDGEolus1402",
                                                "meter_id" => "05219047"})
      end
      
      it 'fetches billing and meter data' do
        WebCaches::SDGE::BillSummary.count.should == 0
        WebCaches::SDGE::BillDetail.count.should == 0
        WebCaches::SDGE::MeterReading.count.should == 0
        VCR.use_cassette("ServiceAccount_fetch_sdge_billing_data_clean_run1", 
                         :match_requests_on => [:method, :uri, :query]) do
          expect {@sdge_account.fetch_billing_data}.to_not raise_error
        end
        # not an elegant test, but true at the time the vcr cassette
        # was recorded
        WebCaches::SDGE::BillSummary.count.should == 25
        WebCaches::SDGE::BillDetail.count.should == 25
        WebCaches::SDGE::MeterReading.count.should == 25
      end

      describe 'after caching' do
        before(:each) do
          # load up the caches
          VCR.use_cassette("ServiceAccount_fetch_sdge_billing_data_clean_run2", 
                           :match_requests_on => [:method, :uri, :query]) do
            @sdge_account.fetch_billing_data
          end
        end

        it 'logs in exactly once' do
          ServiceProvider::SDGELoader.any_instance.should_receive(:login).once.and_call_original
          VCR.use_cassette("ServiceAccount_fetch_sdge_billing_data_clean_run3", 
                           :match_requests_on => [:method, :uri, :query]) do
            expect {@sdge_account.fetch_billing_data}.to_not raise_error
          end
        end

        it 'does not access remote site for individual bills' do
          ServiceProvider::SDGELoader.any_instance.should_not_receive(:fetch_billing_summary_from_remote)
          ServiceProvider::SDGELoader.any_instance.should_not_receive(:fetch_billing_details_from_remote)
          ServiceProvider::SDGELoader.any_instance.should_not_receive(:fetch_meter_reading_from_remote)
          VCR.use_cassette("ServiceAccount_fetch_sdge_billing_data_clean_run4", :tag => :with_time_frozen) do
            begin
              @sdge_account.fetch_billing_data.should == @sdge_account
              @sdge_account.next_fetch_at.should be_instance_of(DateTime)
              @sdge_account.next_fetch_at.should > DateTime.now
            ensure
              Timecop.return
            end
          end
        end

      end
      
    end

  end

end
