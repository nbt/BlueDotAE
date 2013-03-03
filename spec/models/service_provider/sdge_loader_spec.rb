require 'spec_helper'
require 'vcr_helper'

describe "SDGE Loader" do

  # TODO: migrate all service_provider specific tests into the
  # service_provider/ subdirectory
  describe "from sdge" do
    before(:each) do
      @sdge_account = FactoryGirl.create(:service_account, 
                                            :loader_class => "SDGELoader",
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
