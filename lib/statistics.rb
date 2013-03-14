# A rudimentary statistics package
#
# NB: Test suite of sorts in 
# http://rb-gsl.rubyforge.org/svn/trunk/rb-gsl/tests/stats.rb

module Statistics
  extend self

  NAN = 0.0/0.0

  def mean(array)
    return NAN unless (array.count > 0)
    sum = 0.0
    array.each {|x| sum += x }
    sum / array.count
  end

  def median(array, needs_sort = true)
    return NAN unless (array.count > 0)
    array = array.sort if needs_sort
    c = array.count
    if (c.odd?)
      array[c/2]            # assume truncating division
    else
      (array[(c/2)-1] + array[c/2]) * 0.5
    end
  end

  def variance(array, bias_corrected = true, mean = nil)
    return NAN if (array.count == 0) || ((array.count == 1) && bias_corrected)
    mean ||= mean(array)
    denominator = (bias_corrected)?(array.count-1):(array.count)
    sum = 0.0
    array.each do |x|
      dif = x - mean
      sum += (dif * dif)
    end
    sum / denominator
  end
    
  def sd(array, bias_corrected=true, mean = nil)
    Math.sqrt(variance(array, bias_corrected, mean))
  end

  # Covariance.  If you already know the mean of the array(s),
  # you can provide them as optional arguments to save time.
  def covariance(a1, a2, bias_corrected = true, mean1 = nil, mean2 = nil)
    raise ArgumentError.new("length of both arrays must match") unless (a1.count == a2.count)
    mean1 ||= mean(a1)
    mean2 ||= mean(a2)
    denominator = (bias_corrected)?(a1.count-1):(a1.count)
    tot = 0.0
    # a1.each_index {|i| tot += (a1[i] * a2[i])}
    # (tot / denominator) - (mean1 * mean2)
    a1.each_index {|i| tot += (a1[i] - mean1) * (a2[i] - mean2)}
    tot / denominator
  end

  def correlation_coefficient(a1, a2, mean1 = nil, mean2 = nil)
    mean1 ||= mean(a1)
    mean2 ||= mean(a2)
    cov = covariance(a1, a2, false, mean1, mean2)
    sd1 = sd(a1, false, mean1)
    sd2 = sd(a2, false, mean2)
    cov / (sd1 * sd2)
  end

  # r_squared is the proportion of a sum of squared values which is
  # accounted for by its regression.  this is equivalent to the square
  # of the correlation_coefficient() (above)
  def r_squared(a1, a2, mean1 = nil, mean2 = nil)
    mean1 ||= mean(a1)
    mean2 ||= mean(a2)
    cov = covariance(a1, a2, false, mean1, mean2)
    var1 = variance(a1, false, mean1)
    var2 = variance(a2, false, mean2)
    cov * cov / (var1 * var2)
  end


  # interquartile_mean() is a useful way to get a robust average in
  # the presence of outliers, combining aspects of both median and
  # mean.  See http://en.wikipedia.org/wiki/Interquartile_mean for
  # more info.
  #
  # We have extended the usual "quartile" threshold of 0.25 to allow
  # other cutofffs: a smaller value eliminates fewer outliers.  a
  # cutoff of 0.0 is identical to regular mean(), a cutoff of 0.5 is
  # identical to a regular median() (for odd length arrays).
  #
  # Returns two values: the interquartile mean, and the weight of
  # contributions, i.e. how many data points contributed to the
  # result.
  def interquartile_mean(array, cutoff = 0.25, needs_sort = true)
    return NAN unless (array.count > 0) && (cutoff <= 0.5)
    # $stderr.puts("interquartile_mean(): a = #{array}")
    array = array.sort if needs_sort
    n = array.size
    lo = n * cutoff
    hi = n * (1.0 - cutoff)

    # Handle edge case where cutoff has eliminated everything except
    # the middle element.  
    return array[lo.floor] if (lo.floor == hi.floor)

    tvalue = 0.0                # accumulated value
    tweight = 0.0               # accumulated weight
    
    # Note that since trimming is symmetrical from both ends of the 
    # array, we count from 0 to n/2 and handle both ends at once.
    for i in 0...n/2
      if (i+1 < lo)
        # trimmed...
      elsif (i < lo)
        # partial coverage
        weight = (i + 1) - lo
        tvalue += (array[i] + array[n-1-i]) * weight
        tweight += 2 * weight
      else
        # full coverage
        tvalue += (array[i] + array[n-1-i])
        tweight += 2.0
      end
    end
    # Include middle element of odd-length arrays.  (Note: because we
    # handled the edge case above, we know here that the weight of the
    # middle element is 1.0)
    if n.odd?
      tvalue += array[n/2]
      tweight += 1
    end

    tvalue / tweight
  end

end
