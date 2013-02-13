require 'spec_helper'
require 'time_utilities'

describe TimeUtilities do

  describe 'with_tz' do

    it 'should create time in the given zone' do
      TimeUtilities.with_tz("America/New_York") { Time.local(2010, 1, 1).zone }.should == "EST"
      TimeUtilities.with_tz("America/New_York") { Time.local(2010, 6, 1).zone }.should == "EDT"
    end

  end

  describe 'offset_days' do

    it 'should add one to an ordinary day' do
      t0 = Time.new(2010, 1, 1)
      t1 = Time.new(2010, 1, 2)
      TimeUtilities.offset_days(t0, 1).should == t1
      (t1 - t0).should == (24 * 60 * 60)
    end

    it 'should handle non-leap year' do
      t0 = Time.new(2010, 2, 28)
      t1 = Time.new(2010, 3, 1)
      TimeUtilities.offset_days(t0, 1).should == t1
      (t1 - t0).should == (24 * 60 * 60)
    end

    it 'should handle leap year' do
      t0 = Time.new(2012, 2, 28)
      t1 = Time.new(2012, 2, 29)
      TimeUtilities.offset_days(t0, 1).should == t1
      (t1 - t0).should == (24 * 60 * 60)
    end

    it 'should handle vernal DST transition' do
      TimeUtilities.with_tz("America/New_York") { 
        t0 = Time.local(2010, 3, 14)
        t1 = Time.local(2010, 3, 15)
        TimeUtilities.offset_days(t0, 1).should == t1
        (t1 - t0).should == (23 * 60 * 60)
      }
    end

    it 'should handle autumnal DST transition' do
      TimeUtilities.with_tz("America/New_York") { 
        t0 = Time.local(2010, 11, 7)
        t1 = Time.local(2010, 11, 8)
        TimeUtilities.offset_days(t0, 1).should == t1
        (t1 - t0).should == (25 * 60 * 60)
      }
    end

  end

  describe 'quantize_time' do
    before(:each) do
      # Thursday, 2012-06-07 08:09:10
      @t0 = Time.local(2012, 6, 7, 8, 9, 10)
    end

    it 'year false' do
      t1 = Time.local(2012, 1, 1, 0, 0, 0)
      TimeUtilities.quantize_time(@t0, :year, false).should == t1
    end

    it 'year true' do
      t1 = Time.local(2013, 1, 1, 0, 0, 0)
      TimeUtilities.quantize_time(@t0, :year, true).should == t1
    end

    it 'month false' do
      t1 = Time.local(2012, 6, 1, 0, 0, 0)
      TimeUtilities.quantize_time(@t0, :month, false).should == t1
    end

    it 'month true' do
      t1 = Time.local(2012, 7, 1, 0, 0, 0)
      TimeUtilities.quantize_time(@t0, :month, true).should == t1
    end

    it 'week false' do
      t1 = Time.local(2012, 6, 3, 0, 0, 0) # Sunday, 2012-06-04
      TimeUtilities.quantize_time(@t0, :week, false).should == t1
    end

    it 'week true' do
      t1 = Time.local(2012, 6, 10, 0, 0, 0) # Sunday, 2012-06-10
      TimeUtilities.quantize_time(@t0, :week, true).should == t1
    end

    it 'day false' do
      t1 = Time.local(2012, 6, 7, 0, 0, 0)
      TimeUtilities.quantize_time(@t0, :day, false).should == t1
    end

    it 'day true' do
      t1 = Time.local(2012, 6, 8, 0, 0, 0)
      TimeUtilities.quantize_time(@t0, :day, true).should == t1
    end

    it 'hour false' do
      t1 = Time.local(2012, 6, 7, 8, 0, 0)
      TimeUtilities.quantize_time(@t0, :hour, false).should == t1
    end

    it 'hour true' do
      t1 = Time.local(2012, 6, 7, 9, 0, 0)
      TimeUtilities.quantize_time(@t0, :hour, true).should == t1
    end

    it 'minute false' do
      t1 = Time.local(2012, 6, 7, 8, 9, 0)
      TimeUtilities.quantize_time(@t0, :minute, false).should == t1
    end

    it 'minute true' do
      t1 = Time.local(2012, 6, 7, 8, 10, 0)
      TimeUtilities.quantize_time(@t0, :minute, true).should == t1
    end

  end

end
