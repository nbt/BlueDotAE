class TimeUtilities

  def self.with_tz(tz)
    prev_tz = ENV['TZ']
    ENV['TZ'] = tz
    yield
  ensure
    ENV['TZ'] = prev_tz
  end

  def self.quantize_time(t, quantization, is_end = false)
    case quantization
    when :year
      t0 = Time.new(t.year, 1, 1)
      is_end ? t0.to_date.next_year(1).to_time : t0
    when :month
      t0 = Time.new(t.year, t.month, 1)
      is_end ? t0.to_date.next_month(1).to_time : t0
    when :week
      d = Date.new(t.year, t.month, t.day) - t.wday
      t0 = Time.new(d.year, d.month, d.day)
      is_end ? offset_days(t0, 7) : t0
    when :day
      t0 = Time.new(t.year, t.month, t.day)
      is_end ? offset_days(t0, 1) : t0
    when :hour
      t0 = Time.new(t.year, t.month, t.day, t.hour)
      is_end ? t0 + 3600 : t0
    when :minute
      t0 = Time.new(t.year, t.month, t.day, t.hour, t.min)
      is_end ? t0 + 60 : t0
    else 
      raise ArgumentError.new("unrecognized quantization, found #{quantization}")
    end
  end
    
  # Return a time offset by n_days.  Account for DST transitions.
  def self.offset_days(t, n_days)
    t2 = t + (n_days * 24 * 60 * 60)
    utc_delta = t.utc_offset - t2.utc_offset
    (utc_delta == 0) ? t2 : t2 + utc_delta
  end
  
end
