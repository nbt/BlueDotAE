require 'spec_helper'
require 'vcr_helper'

describe "ServiceProvider::SDGE" do
  before(:each) do
    reset_db
    valid_credentials = { "user_id" => "ChrisWrightFamily", "password" => "SDGEolus1402" }
    invalid_credentials = { :foo => :bar }
    @subaccounts = ["05219047", "01046957"]

    @valid_sdge = ServiceProvider::SDGE.new(valid_credentials)
    @invalid_sdge = ServiceProvider::SDGE.new(invalid_credentials)

    @valid_subaccount = @subaccounts.first
    @invalid_subaccount = "i am a teapot"
  end

  describe "initialize" do
    it 'creates a ServiceProvider' do
      sdge = ServiceProvider::SDGE.new(nil)
      sdge.should_not be_nil
    end
  end

  describe 'probe' do

    it 'with valid credentials returns true' do
      @valid_sdge.probe.should be_true
    end

    it 'with invalid credentials returns an error string' do
      @invalid_sdge.probe.should_not == true
    end
  end

  describe 'home_page' do

    it 'should not raise an error with valid credentials' do
      VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
        expect {@valid_sdge.home_page}.to_not raise_error
      end
    end

    it 'called multiple times should call login only once' do
      @valid_sdge.should_receive(:login).once.and_call_original
      VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
        @valid_sdge.home_page
        @valid_sdge.home_page
      end
    end

    it 'should raise an error with invalid credentials' do
      expect {@invalid_sdge.home_page}.to raise_error
    end
      
  end

  describe 'login' do

    it 'should not raise an error with valid credentials' do
      VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
        expect {@valid_sdge.login}.to_not raise_error
      end
    end

    it 'should raise an error with invalid credentials' do
      VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
        expect {@invalid_sdge.login}.to raise_error
      end
    end
  end

  describe 'logout' do
    it 'should force a second call to login' do
      @valid_sdge.should_receive(:login).twice.and_call_original
      VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
        @valid_sdge.home_page
        @valid_sdge.home_page
        @valid_sdge.logout
        @valid_sdge.home_page
      end
    end

  end

  describe 'subaccount-aware' do

    describe 'subaccounts' do
      it 'given a valid account should return a list' do
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          @valid_sdge.subaccounts.should =~ @subaccounts
        end
      end
      it 'given an invalid account should raise an error' do
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          expect {@invalid_sdge.subaccounts}.to raise_error
        end
      end
    end

    describe 'service_address' do
      it 'given a valid account and valid subaccount returns an address' do
        pending "vcr cassette needs refreshing?"
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          @valid_sdge.service_address(@valid_subaccount).should =~ /1402 Eolus Av/i
        end
      end
      it 'given a valid account and invalid subaccount raises error' do
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          expect {@valid_sdge.service_address(@invalid_subaccount)}.to raise_error
        end
      end
      it 'given an invalid account and valid subaccount raises error' do
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          expect {@invalid_sdge.service_address(@valid_subaccount)}.to raise_error
        end
      end
    end

    describe 'fetch_billing_data' do
      it 'given a valid account and subaccount returns a hash' do
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          r = @valid_sdge.fetch_billing_data(@valid_subaccount)
          r.keys.should =~ [:start_date, :end_date, :next_check_at]
          r.values.all? {|e| e.kind_of?(DateTime)}.should be_true
        end
      end
      it 'given a valid account and invalid subaccount raises error' do
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          expect {@valid_sdge.service_address(@invalid_subaccount)}.to raise_error
        end
      end
      it 'given an invalid account and valid subaccount raises error' do
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          expect {@invalid_sdge.service_address(@valid_subaccount)}.to raise_error
        end
      end
      it 'caches summaries, details and readings' do
        WebCaches::SDGE::BillSummary.count.should == 0
        WebCaches::SDGE::BillDetail.count.should == 0
        WebCaches::SDGE::MeterReading.count.should == 0
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          @valid_sdge.fetch_billing_data(@valid_subaccount)
        end
        # not an elegant test, but true at the time the vcr cassette
        # was recorded
        WebCaches::SDGE::BillSummary.count.should == 25
        WebCaches::SDGE::BillDetail.count.should == 25
        WebCaches::SDGE::MeterReading.count.should == 25
      end
    end

    describe 'with cached data' do
      before(:each) do
        # load up the caches
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          @valid_sdge.fetch_billing_data(@valid_subaccount)
        end
      end
      it 'logs in exactly once' do
        @valid_sdge.should_not_receive(:login) # the before :each has already logged us in
        VCR.use_cassette(example.metadata[:full_description], :match_requests_on => [:method, :uri, :query]) do
          @valid_sdge.fetch_billing_data(@valid_subaccount)
        end
      end

      it 'does not access remote site for individual bills' do
        # explanation: since the before :each fetch_billing_data
        # loaded up the web caches, we should not see any further
        # attempts to access the remote except to log in.
        ServiceProvider::SDGE.any_instance.should_not_receive(:fetch_billing_summary_from_remote)
        ServiceProvider::SDGE.any_instance.should_not_receive(:fetch_billing_details_from_remote)
        ServiceProvider::SDGE.any_instance.should_not_receive(:fetch_meter_reading_from_remote)
        VCR.use_cassette(example.metadata[:full_description]) do
          @valid_sdge.fetch_billing_data(@valid_subaccount)
        end
      end
      
    end                         # describe 'with cached data' do

  end                           # describe 'subaccount-aware' do

end                             # describe "ServiceProvider::SDGE" do
