require 'spec_helper'

describe "ServiceProvider::Test" do
  before(:each) do
    @valid_test = ServiceProvider::Test.new(ServiceProvider::Test::VALID_CREDENTIALS)
    @invalid_test = ServiceProvider::Test.new({:foo => :bar})
  end

  describe 'initialize' do

    it 'creates a ServiceAccount' do
      test = ServiceProvider::Test.new(nil)
      test.should_not be_nil
    end

  end

  describe 'probe' do

    it 'with valid credentials returns true' do
      @valid_test.probe.should be_true
    end

    it 'with invalid credentials returns an error string' do
      @invalid_test.probe.should_not == true
    end
  end

  describe 'home_page' do

    it 'should not raise an error with valid credentials' do
      expect {@valid_test.home_page}.to_not raise_error
    end

    it 'called multiple times should call login only once' do
      @valid_test.should_receive(:login).once.and_call_original
      @valid_test.home_page
      @valid_test.home_page
    end

    it 'should raise an error with invalid credentials' do
      expect {@invalid_test.home_page}.to raise_error
    end
      
  end

  describe 'login' do

    it 'should not raise an error with valid credentials' do
      expect {@valid_test.login}.to_not raise_error
    end

    it 'should raise an error with invalid credentials' do
      expect {@invalid_test.login}.to raise_error
    end
  end

  describe 'logout' do
    it 'should foce a second call to login' do
      @valid_test.should_receive(:login).twice.and_call_original
      @valid_test.home_page
      @valid_test.home_page
      @valid_test.logout
      @valid_test.home_page
    end

  end

  describe 'subaccounts' do
    it 'given a valid account should return a list' do
      @valid_test.subaccounts.should == ServiceProvider::Test::SUBACCOUNTS
    end
    it 'given an invalid account should raise an error' do
      expect {@invalid_test.subaccounts}.to raise_error
    end
  end

  describe 'subaccount-aware' do
    before(:each) do
      @valid_subaccount = ServiceProvider::Test::SUBACCOUNTS.first
      @invalid_subaccount = :not_your_grandmothers_subaccount
    end

    describe 'service_address' do
      it 'given a valid account and valid subaccount returns an address' do
        @valid_test.service_address(@valid_subaccount).should == ServiceProvider::Test::SERVICE_ADDRESS
      end
      it 'given a valid account and invalid subaccount raises error' do
        expect {@valid_test.service_address(@invalid_subaccount)}.to raise_error
      end
      it 'given an invalid account and valid subaccount raises error' do
        expect {@invalid_test.service_address(@valid_subaccount)}.to raise_error
      end
    end

    describe 'fetch_billing_data' do
      it 'given a valid account and valid subaccount returns an address' do
        r = @valid_test.fetch_billing_data(@valid_subaccount)
        r.keys.should =~ [:start_date, :end_date, :next_check_at]
        r.values.all? {|e| e.kind_of?(DateTime)}.should be_true
      end
      it 'given a valid account and invalid subaccount raises error' do
        expect {@valid_test.service_address(@invalid_subaccount)}.to raise_error
      end
      it 'given an invalid account and valid subaccount raises error' do
        expect {@invalid_test.service_address(@valid_subaccount)}.to raise_error
      end
    end

  end
end
