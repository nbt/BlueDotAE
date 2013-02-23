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

  describe "fetch_billing_data" do
    before(:each) do
    end
    
    it 'should call the underlying loader class' do
      date = DateTime.new(2012, 1, 1)
      service_account = ServiceAccount.create(:loader_class => "LoaderBase")
      ServiceProvider::LoaderBase.should_receive(:fetch_billing_data).with(service_account)
      expect {service_account.fetch_billing_data}.to_not raise_error
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
              @sdge_account.fetch_billing_data
            ensure
              Timecop.return
            end
          end
        end

      end
      
    end

  end

end
