module ServiceProvider

  class SDGELoader < LoaderBase

    SDGE_PORTAL = "https://myaccount.sdge.com"
    SDGE_LOGOUT = "https://myaccount.sdge.com/myAccount/pageFlows/signOut/SignOutController.jpf"

    # Navigate to the user's home page, logging in if needed.
    # returns the home page.
    def home_page
      return login unless (page = web_agent.history.last)
      # we have a page.  login if it lacks a "My Account" link
      return login unless (link = page.link_with(:text => /My Account/))
      # follow the link to make sure we're still logged in
      page = link.click
      return login unless page.link_with(:text => /My Account/)
      # we're now on the home page and logged in
      page
    end
      
    def login
      url = "#{SDGE_PORTAL}/myAccount/myAccount.portal"
      page = web_agent.get(url)
      raise(LoadError.new("failed to get login page")) unless page
      login_form = page.forms.find {|f| f.name =~ /Login/}
      raise(LoadError.new("failed to get login form")) unless login_form
      login_form['USER'] = service_account.credentials["user_id"]
      login_form['PASSWORD'] = service_account.credentials["password"]
      page = web_agent.submit(login_form)
      # submit form and make sure we're logged in (should NOT have login form)
      form = page.forms.find {|f| f.name =~ /Login/}
      raise(LoadError.new("login failed - is your User ID and Password correct?")) if form
      page
    end

    def logout
      set_status("logging out of #{company_name} site")
      web_agent.get(SDGE_LOGOUT)
      # meh
      set_status("log out completed")
    end

    # ================================================================
    # etl_service_bill
    
    # TODO: implement me

    # ================================================================
    # etl_meter_readings

    # Return a raw page contains meter readings.  This is the only
    # code to hit the remote server, so if we can find a cached
    # version of the data, we use that.
    def extract_meter_readings
      cache_key = self.class.name + __method__.to_s + service_account.credentials["meter_id"].to_s + start_time.to_s
      WebCache.with_db_cache(cache_key) {|k| extract_meter_readings_from_remote }
    end
    
    def extract_meter_readings_from_remote
      # log in as needed
      p1 = home_page
      raise LoadError.new("cannot log in") unless p1

      # click [My Energy]
      l1 = p1.link_with(:text => /My Energy/)
      raise(LoadError.new("failed to get My Energy link")) unless l1
      p2 = l1.click

      # click [My Energy Use]
      l2 = p2.link_with(:text => /\AMy Energy Use\Z/)
      raise(LoadError.new("failed to get My Energy Use link")) unless l2
      p3 = l2.click
        
      # confirm acceptance if needed (still needed???)
      # link = page.link_with(:text => /I understand/)
      # page = link.click if (link)

      # navigate to GreenButton
      p4 = web_agent.get('/LoadAnalysis/GreenButton.aspx')

      # The following isn't required except to validate parameters
      # TODO: If we switch meters, we may need to submit the form
      # specifically to discover minDate, maxDate, maxDataAllowed
      f4 = p4.form_with(:name => "Form1")
      # $stderr.puts("=== meter ids = #{f4.field_with(:name => 'ddlMeters').options}")
      # $stderr.puts("=== earliest day = #{f4.field_with(:name => 'minDate').value}")
      # $stderr.puts("=== latest day = #{f4.field_with(:name => 'maxDate').value}")
      # $stderr.puts("=== max days = #{f4.field_with(:name => 'maxDataAllowed').value}")

      # Submit request for data
      st = TimeUtilities.quantize_time(self.start_time, :month)
      et = TimeUtilities.offset_days(TimeUtilities.quantize_time(self.start_time, :month, true), -1)
      # TODO: pass IANA time zone as an argument.
      # TODO: try passing UTC as an argument to fix problem noted 
      # in translate_meter_readings -- what happens then?
      params = {
        "MeterId" => service_account.credentials["meter_id"].to_s,
        "StartDate" => st.strftime("%m/%d/%Y"),
        "EndDate" => et.strftime("%m/%d/%Y"),
        "OlsonTimeZoneKey" => "America/Los_Angeles"
      }
      query_string = params.map {|k,v| "#{CGI.escape(k)}=#{CGI.escape(v)}"}.join("&")
      p5 = web_agent.get("/LoadAnalysis/Handlers/GreenButtonHandler.ashx?#{query_string}")

      # Extract resulting filename 
      json = JSON.load(p5.body)
      filename = json["FileName"]
      # TODO: consider using a raw Net::HTTP.get() so we cache the
      # entire request/response and not just the zip file -- might
      # simplify error recovery.
      p6 = web_agent.get("/LoadAnalysis/Handlers/GreenButtonHandler.ashx?file=&name=#{filename}.zip")

      # p6.body now contains a .zip file
    end

    # mechanize_page is a Mechanize::Page object whose #body is a zip
    # file of the XML with meter readings.  translate it into array of
    # hash objects, suitable for instantiation as MeterReading objects
    def translate_meter_readings(mechanize_page)
      unzipped = unzip(mechanize_page.body)
      xml_entry = unzipped.find {|k, v| k =~ /.*\.xml$/ }
      raise LoadError.new("cannot locate xml data") unless xml_entry
      xml_doc = Nokogiri::XML(xml_entry[1])
      # see [nokogiri-talk] doc.xpath() abysmally slow
      readings = if (true)
                   xml_doc.remove_namespaces!
                   xml_doc.xpath('//IntervalBlock//IntervalReading')
                 else
                   xml_doc.xpath('//meter:IntervalBlock/meter:IntervalReading', 
                                 'meter' => "http://naesb.org/espi")
                 end
      hourly = readings.map do |reading|
        # NB: The GreenButton data timePeriod/start is evidently in
        # UTC, but it correctly should be in local time.
        #
        # TODO: figure out proper way to set offset timePeriod/start
        # to correct time zone
        date = Time.at(reading.xpath('./timePeriod/start').text.to_i).getlocal(0)
        duration_s = reading.xpath('./timePeriod/duration').text.to_i
        quantity = reading.xpath('./value').text.to_f
        {:service_account => service_account,
          :date => date,
          :duration_s => duration_s,
          :quantity => quantity}
      end

    end
    
  end
  
end