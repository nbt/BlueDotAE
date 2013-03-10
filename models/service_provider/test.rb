# ServiceProvider::Test simplifies testing.  It never accesses the
# web, but it does create a dummy cached record in response to
# fetch_billing_data and conforms to the ServiceProvider::Base
# interface.

module ServiceProvider

  class Test < ServiceProvider::Base

    VALID_CREDENTIALS = {:user_id => "rosco", :password => "ocsor"}
    SUBACCOUNTS = [:electricity7890, :gas0123]
    START_DATE = DateTime.new(2010, 1, 1)
    END_DATE = DateTime.new(2011, 1, 1)
    NEXT_CHECK_AT = DateTime.new(2012, 1, 1)
    SERVICE_ADDRESS = "123 Mulberry Street, Springfield IM, 20332, USA"

    def login
      raise(LoadError.new("login failed")) unless credentials_valid?
      return "a page"
    end

    def subaccounts
      home_page                 # pretend we need to log in to access
      SUBACCOUNTS
    end

    def service_address(subaccount)
      raise LoadError.new("unrecognized subaccount #{subaccount}") unless subaccount_valid?(subaccount)
      SERVICE_ADDRESS
    end

    def fetch_billing_data(subaccount)
      raise LoadError.new("unrecognized subaccount #{subaccount}") unless subaccount_valid?(subaccount)
      home_page
      key = "#{VALID_CREDENTIALS[:user]} subaccount #{subaccount}"
      WebCaches::Test.fetch(key) {
        "#{VALID_CREDENTIALS[:user]} was here for #{subaccount}"
      }
      { :start_date => START_DATE,
        :end_date => END_DATE,
        :next_check_at => NEXT_CHECK_AT
      }
    end

    private
    
    def credentials_valid?
      credentials == VALID_CREDENTIALS
    end

    def subaccount_valid?(subaccount)
      return subaccounts.member?(subaccount)
    end

  end

end
