# ServiceProvider::Test simplifies testing.  It never accesses the
# web, but it does create a dummy cached record in response to
# fetch_billing_data and conforms to the ServiceProvider::Base
# interface.

module ServiceProvider

  class Test < ServiceProvider::Base

    VALID_USERID = "rosco"
    VALID_PASSWD = "ocsor"
    START_DATE = DateTime.new(2010, 1, 1)
    END_DATE = DateTime.new(2011, 1, 1)
    NEXT_CHECK_AT = DateTime.new(2012, 1, 1)

    def fetch_billing_data
      raise(LoadError.new("login failed")) unless credentials_valid?
      WebCaches::Test.fetch(VALID_USERID) {
        "#{VALID_USERID} was here"
      }
      { :start_date => START_DATE,
        :end_date => END_DATE,
        :next_check_at => NEXT_CHECK_AT
      }
    end

    private
    
    def credentials_valid?
      service_account.credentials["user_id"] == VALID_USERID &&
        service_account.credentials["password"] == VALID_PASSWD &&
    end

  end

end
