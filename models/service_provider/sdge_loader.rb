module ServiceProvider

  class SDGELoader < LoaderBase

    SDGE_PORTAL = "https://myaccount.sdge.com"
    SDGE_LOGOUT = "https://myaccount.sdge.com/myAccount/pageFlows/signOut/SignOutController.jpf"

    # The contract of fetch_billing_data is to access the remote web
    # site and download all available billing and interval data for a
    # specific account that has not already been downloaded.  It saves
    # three different raw data types for each account and date range:
    #
    #   billing_summary (class: Mechanize::Page, format: HTML)
    #   billing_details (class: String, format: pdf)
    #   meter_readings (class: String, format: zipped XML)
    #
    # The following methods create keys to access the saved raw
    # data in WebCache.

    def self.billing_summary_cache_key(account_id, billing_date)
      sprintf("%s_%s_%s_%s", 
              self.name, 
              __method__.to_s, 
              account_id.to_s, 
              date_to_key(billing_date))
    end

    def self.billing_details_cache_key(account_id, start_date, end_date)
      sprintf("%s_%s_%s_%s_%s", 
              self.name, 
              __method__.to_s, 
              account_id.to_s, 
              date_to_key(start_date),
              date_to_key(end_date))
    end

    def self.meter_readings_cache_key(account_id, start_date, end_date)
      sprintf("%s_%s_%s_%s_%s", 
              self.name, 
              __method__.to_s, 
              account_id.to_s, 
              date_to_key(start_date),
              date_to_key(end_date))
    end

    def self.date_to_key(date)
      date.strftime("%Y-%m-%d")
    end

    # fetch_billing_data accesses the utility web site and download
    # all available billing and interval data that has not yet already
    # been downloaded.  The result of this is to add records to the
    # WebCache database table.  The status of the fetch process (along
    # with any failures) are logged in a log file.
    #
    # +fetch_billing_data+ ultimately returns the date/time at which
    # we should next call the method, presumably when the remote data
    # site will have new data to offer, or nil if some unrecoverable
    # error indicates that future attempts will fail.
    #
    # Implementation: Log into the SDGE site and navigate to the bill
    # summary page.  A pull-down list contains links to all available
    # bills.  For each bill summary, fetch the start and stop date of
    # the billing period.  Then use these dates to fetch the billing
    # details and metere readings for that date range.
    #
    def fetch_billing_data
      # log into the remote site to get an summary list of available bills
      p1 = home_page
      raise LoadError.new("cannot log in") unless p1

      l1 = p1.link_with(:text => "My Bills & Payments")
      raise LoadError.new("failed to get My Bills & Payments link") unless l1
      p2 = l1.click

      l2 = p2.link_with(:text=>/^Bill$/)
      raise LoadError.new("failed to get Bill link") unless l2
      p3 = l2.click

      f3 = p3.form_with(:name => /displayForm/)
      o3 = f3.field_with(:name => /^docId$/).options

      billing_dates = o3.map {|option| fetch_monthly_bills(f3, option)}

      # At this point, we have cached both the billing_summary and the
      # billing_details for all available bills.  billing_dates is a
      # list of [[start1, end1], [start2, end2], ...].  Use this list
      # to fetch one xml file for each corresponding billing_detail.

      fetch_meter_readings(billing_dates)

      # finally, return the next date at which we should re-check the 
      # web site
      
      first_bill_ending_date = billing_dates[0][1]
      next_check_date(first_bill_ending_date)

    end

    # Fetch monthly bill summary from remote site (or from local cache
    # if available) in order to find start_date and end_date of each
    # billing cycle.  While we're at it, fetch the monthly bill detail
    # from the remote site (or from the local cache, if available).
    #
    # Return [index, start_date, end_date(exclusive)] for each 
    # available bill
    def fetch_monthly_bills(form, option)
      start_date, end_date = fetch_billing_summary(form, option)
      fetch_billing_details(form, option, start_date, end_date)

      # finally return [start_date, end_date]
      [start_date, end_date]
    end

    # our best guess as to when to next poll the remote site.
    # TODO: could be better
    def next_check_date(ending_date)
      ending_date + 31
    end

    # ================================================================
    # billing summary

    def fetch_billing_summary(form, option)
      date = translate_mmddyy(option.text)
      summary_key = self.class.billing_summary_cache_key(service_account.credentials["meter_id"], date)
      body = WebCaches::SDGE::BillSummary.fetch(summary_key) do
        page = fetch_billing_summary_from_remote(form, option)
        page.body
      end
      parse_start_and_end_date(body)
    end

    # parse [start_date, end_date] of billing cycle from the billing
    # summary contained in html body.
    def parse_start_and_end_date(body)
      # parse page to find start date and end date
      doc = Nokogiri::HTML(body)
      nodes = doc.xpath('//edx_table/tr[1]//td[2]')
      raise RecordError.new("failed to find start and end dates") unless nodes.count == 2
      str = nodes.last.text
      # str is of the form "Jan 11, 2013 - Feb 11, 2013"
      raise RecordError.new("failed to find start and end dates") unless (str =~ /(.*) - (.*)/)
      start_date = DateTime.parse($1)
      end_date = DateTime.parse($2)
      [start_date, end_date]
    end

    def fetch_billing_summary_from_remote(form, option)
      form['docId'] = option.value
      form.submit
    end

    # ================================================================
    # billing details
    # vivant - security co

    def fetch_billing_details(form, option, start_date, end_date)
      details_key = self.class.billing_details_cache_key(service_account.credentials["meter_id"],
                                                         start_date,
                                                         end_date)
      WebCaches::SDGE::BillDetail.fetch(details_key) { 
        fetch_billing_details_from_remote(form, option) 
      }
    end

    def fetch_billing_details_from_remote(form, option)
      form['docId'] = option.value
      p10 = form.submit
      l10 = p10.link_with(:text => /View Detailed Bill/)
      raise RecordError.new("failed to find link for detailed bill") unless l10

      p11 = l10.click
      f11 = p11.frame_with(:name => "pdf_frame")
      raise RecordError.new("failed to find frame for detailed bill") unless f11

      p12 = f11.click
      File.open("/tmp/#{Time.now.iso8601}.pdf", "wb") {|f| f.print(p12.body)}
      p12.body
    end

    # ================================================================
    # meter readings

    # Fetch the zipped XML files for each billing period named in 
    # billing dates, skipping any that have already been fetched.
    def fetch_meter_readings(billing_dates)
      billing_dates.each do |start_date, end_date|
        # $stderr.puts("=== fetch_meter_reading(#{start_date.iso8601}, #{end_date.iso8601})")
        fetch_meter_reading(start_date, end_date)
      end
    end

    def fetch_meter_reading(start_date, end_date)
      readings_key = self.class.meter_readings_cache_key(service_account.credentials["meter_id"],
                                                         start_date,
                                                         end_date)
      WebCaches::SDGE::MeterReading.fetch(readings_key) { 
        # Slight magic here: If fetch_meter_reading_from_remote raises
        # an RecordError, we store the RecordError itself in the
        # cache.  This prevents us from re-trying a remote read every
        # time, but code that accesses pages from the cache must check
        # to see what object is being returned.
        begin
          fetch_meter_reading_from_remote(start_date, end_date) 
        rescue RecordError => e
          $stderr.print("\n=== rescued #{e.inspect}")
          e
        end
      }
    end

    def fetch_meter_reading_from_remote(start_date, end_date)
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

      end_date_inclusive = end_date - 1

      # The following isn't required except to validate parameters
      # TODO: If we switch meters, we may need to submit the form
      # specifically to discover minDate, maxDate, maxDataAllowed
      f4 = p4.form_with(:name => "Form1")
      meter_ids = f4.field_with(:name => 'ddlMeters').options
      min_date = f4.field_with(:name => 'minDate').value.to_i
      max_date = f4.field_with(:name => 'maxDate').value.to_i
      max_days = f4.field_with(:name => 'maxDataAllowed').value.to_i

      now = DateTime.now
      midnight = DateTime.civil(now.year, now.month, now.day, 0, 0, 0, "+0")
      oldest_available = midnight + min_date
      newest_available = midnight + max_date

      # $stderr.puts("=== #{start_date.iso8601}--#{end_date_inclusive.iso8601}  #{oldest_available.iso8601}--#{newest_available.iso8601}")
      raise(RecordError.new("skipping because #{start_date} falls before #{oldest_available}")) if (start_date < oldest_available)
      raise(RecordError.new("skipping because #{end_date_inclusive} falls after #{newest_available}")) if (end_date_inclusive > newest_available)
        
      # Submit request for data
      # TODO: pass IANA time zone as an argument.
      # TODO: try passing UTC as an argument to fix problem noted 
      # in translate_meter_readings -- what happens then?
      params = {
        "MeterId" => service_account.credentials["meter_id"].to_s,
        "StartDate" => start_date.strftime("%m/%d/%Y"),
        "EndDate" => end_date_inclusive.strftime("%m/%d/%Y"),
        "OlsonTimeZoneKey" => "America/Los_Angeles"
      }
      query_string = params.map {|k,v| "#{CGI.escape(k)}=#{CGI.escape(v)}"}.join("&")

      p5 = web_agent.get("/LoadAnalysis/Handlers/GreenButtonHandler.ashx?#{query_string}")

      # Fetch resulting filename 
      json = JSON.load(p5.body)
      raise(RecordError.new("failed to load interval data: #{json['ErrorMessage']}")) if json['ErrorMessage']
      filename = json["FileName"]

      # return the ZIP file
      web_agent.get("/LoadAnalysis/Handlers/GreenButtonHandler.ashx?file=&name=#{filename}.zip")
    end

    # ================================================================
    # ================================================================

    # Navigate to the user's home page, logging in if needed.
    # returns the home page.
    def home_page
      @home_page ||= login
    end
      
    def login
      # $stderr.print("=== logging in...")
      url = "#{SDGE_PORTAL}/myAccount/myAccount.portal"
      page = web_agent.get(url)
      raise(LoadError.new("failed to get login page")) unless page
      login_form = page.forms.find {|f| f.name =~ /Login/}
      raise(LoadError.new("failed to get login form")) unless login_form
      login_form['USER'] = service_account.credentials["user_id"]
      login_form['PASSWORD'] = service_account.credentials["password"]
      # submit form and make sure we're logged in (should NOT have login form)
      page = web_agent.submit(login_form)
      raise(LoadError.new("login failed -- is your User ID and Password correct?")) unless logged_in?(page)
      # $stderr.puts("... logged in")
      page
    end

    def logged_in?(page)
      !!page.link_with(:text => /My Account/)
    end

    def logout
      set_status("logging out of #{company_name} site")
      web_agent.get(SDGE_LOGOUT)
      # meh
      set_status("log out completed")
    end

    # ================================================================
    # ================================================================
    # ================================================================
    #
    # Translate and load

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
    
    # ================================================================
    # ================================================================

  end
  
end
