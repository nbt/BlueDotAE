require 'spec_helper'

describe Statistics do
  before(:each) do
    # taken from http://rb-gsl.rubyforge.org/svn/trunk/rb-gsl/tests/stats.rb

    @lew = [ -213, -564, -35, -15, 141, 115, -420, -360, 203, -338,
    -431, 194, -220, -513, 154, -125, -559, 92, -21, -579, -52, 99,
    -543, -175, 162, -457, -346, 204, -300, -474, 164, -107, -572, -8,
    83, -541, -224, 180, -420, -374, 201, -236, -531, 83, 27, -564,
    -112, 131, -507, -254, 199, -311, -495, 143, -46, -579, -90, 136,
    -472, -338, 202, -287, -477, 169, -124, -568, 17, 48, -568, -135,
    162, -430, -422, 172, -74, -577, -13, 92, -534, -243, 194, -355,
    -465, 156, -81, -578, -64, 139, -449, -384, 193, -198, -538, 110,
    -44, -577, -6, 66, -552, -164, 161, -460, -344, 205, -281, -504,
    134, -28, -576, -118, 156, -437, -381, 200, -220, -540, 83, 11,
    -568, -160, 172, -414, -408, 188, -125, -572, -32, 139, -492,
    -321, 205, -262, -504, 142, -83, -574, 0, 48, -571, -106, 137,
    -501, -266, 190, -391, -406, 194, -186, -553, 83, -13, -577, -49,
    103, -515, -280, 201, 300, -506, 131, -45, -578, -80, 138, -462,
    -361, 201, -211, -554, 32, 74, -533, -235, 187, -372, -442, 182,
    -147, -566, 25, 68, -535, -244, 194, -351, -463, 174, -125, -570,
    15, 72, -550, -190, 172, -424, -385, 198, -218, -536, 96]

    @rawa = [ 0.0421, 0.0941, 0.1064, 0.0242, 0.1331,0.0773, 0.0243,
              0.0815, 0.1186, 0.0356, 0.0728, 0.0999, 0.0614, 0.0479]

    @rawa_mean = 0.0728

    @rawb = [ 0.1081, 0.0986, 0.1566, 0.1961, 0.1125, 0.1942, 0.1079,
              0.1021, 0.1583, 0.1673, 0.1675, 0.1856, 0.1688, 0.1512]

    @raww = [ 0.0000, 0.0000, 0.0000, 3.000, 0.0000, 1.000, 1.000,
              1.000, 0.000, 0.5000, 7.000, 5.000, 4.000, 0.123]
    
  end
  
  describe 'mean' do
    
    it 'returns NAN on empty array' do
      Statistics.mean([]).should be_nan
    end
    
    it 'returns value for singleton array' do
      Statistics.mean([1.0]) == 1.0
    end
    
    it 'returns mean of lew' do
      Statistics.mean(@lew).should be_within(0.0001).of(-177.435)
    end
    
    it 'returns mean of rawa' do
      Statistics.mean(@rawa).should be_within(0.0001).of(@rawa_mean)
    end
    
  end
  
  describe 'median' do
    
    it 'from empty array' do
      Statistics.median([]).should be_nan
    end

    it 'from singleton array' do
      Statistics.median([2.0]) == 2.0
    end

    it 'from even length array' do
      Statistics.median(@rawa).should be_within(0.0001).of(0.07505)
    end

    it 'from even length sorted array' do
      @rawa.sort!
      Statistics.median(@rawa, false).should be_within(0.0001).of(0.07505)
    end

    it 'from odd length sorted array' do
      @rawa.sort!
      Statistics.median(@rawa.take(@rawa.size-1), false).should be_within(0.0001).of(0.0728)
    end

  end

  describe 'variance' do

    it 'from empty array' do
      Statistics.variance([]).should be_nan
    end

    it 'rawa variance' do
      Statistics.variance(@rawa).should be_within(0.0001).of(0.00113837428571429)
    end

    it 'rawa variance with mean' do
      Statistics.variance(@rawa, true, @rawa_mean).should be_within(0.0001).of(0.00113837428571429)
    end

    it 'rawa variance bias uncorrected' do
      Statistics.variance(@rawa, false).should be_within(0.0001).of(0.00113837428571429)
    end

    it 'rawb variance' do
      Statistics.variance(@rawb).should be_within(0.0001).of(0.00124956615384615)
    end

  end

  describe 'sd' do

    it 'lew' do
      Statistics.sd(@lew).should be_within(0.0001).of(277.332168044316)
    end

    it 'rawa' do
      Statistics.sd(@rawa, false).should be_within(0.0001).of(0.0337398026922845)
    end
      
    it 'rawa with mean' do
      Statistics.sd(@rawa, false, @rawa_mean).should be_within(0.0001).of(0.0337398026922845)
    end
      
  end

  describe 'covariance' do

    it 'raises error on mismatched length' do
      expect { Statistics.covariance(@rawa, @rawb.drop(1))}.to raise_error
    end

    it 'rawa rawb' do
      Statistics.covariance(@rawa, @rawb).should be_within(0.0001).of(-0.000139021538461539)
    end

  end

  describe 'correlation_coefficient' do
  end

  describe 'r_squared' do
  end

  describe 'interquartile_mean' do
    before(:each) do
      @odd = [1, 10, 11, 12, 20]
      @even = [1, 10, 11, 12, 13, 20]
    end

    it 'on odd' do
      Statistics.interquartile_mean(@odd).should == 11
    end

    it 'on even' do
      Statistics.interquartile_mean(@even).should == 11.5
    end      
    
    it 'with cutoff = 0 acts like mean' do
      Statistics.interquartile_mean(@odd, 0).should == Statistics.mean(@odd)
      Statistics.interquartile_mean(@even, 0).should == Statistics.mean(@even)
    end
      
    it 'with cutoff = 0.5 acts like median for odd length arrays' do
      Statistics.interquartile_mean(@odd, 0.5).should == Statistics.median(@odd)
    end
      
  end

end
