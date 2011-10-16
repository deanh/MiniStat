require 'mathn'

module MiniStat
  class Data
    include Enumerable

    attr_reader :data

    def initialize(d)
      @data   = d.map { |n| n.to_f }.sort
      @sorted = true
      clear_results
    end

    def <<(obj)
      throw "#{obj.to_s} is not numeric" unless obj.to_f
      @data << obj
      # force computation!
      clear_results
      @sorted = false
      obj
    end

    def each(&block)
      @data.each(&block)
    end

    def clear_results
      @q1, @q3, @iqr, @outliers, @std_dev, @variance  = nil
      @mode, @harmonic_mean, @geometric_mean          = nil
    end

    ##
    # Return the median of +data+. Naive implementaion
    # -- does a sort on the data.
    def median(data=@data)
      unless @sorted and data == @data
        data.sort!
        @sorted = true
      end
      if data.size % 2 == 0
        return (data[data.size / 2.0 - 1] + data[(data.size / 2.0)]) / 2.0
      else 
        return data[(data.size - 1)/2.0]
      end
    end

    ##
    # Partition a set of numbers about +pivot+
    def partition(pivot, data=@data)
      low  = []
      high = []
      data.each do |i|
        high.push(i) if i > pivot
        low.push(i)  if i < pivot
      end
      return {:low => low, :high => high}
    end

    ##
    # A note on quartiles: the below methods DO NOT produce results
    # that agree with R's default approach. There is no "one true"
    # method for producing quartiles--R's default is that of S, the
    # code below uses another (which I find simpler).  See:
    # http://en.wikipedia.org/wiki/Quartile for details

    ##
    # First quartile.
    def q1
      @q1 ||= median(partition(median(@data), @data)[:low])
    end

    ##
    # Third quartile
    def q3
      @q3 ||= median(partition(median(@data), @data)[:high])
    end

    ##
    # Interquartile range, ie, the middle 50% of the data.
    def iqr
      @iqr ||= q3 - q1
    end

    ##
    # Returns an array of outlying data points.
    def outliers
      @outliers ||= 
        @data.map do |i|
          i  if (i < q1 - (1.5 * iqr) or i > q3 + (1.5 * iqr))
        end.compact
    end

    ##
    # Computes arthmetic mean (most common average).
    def mean(data=@data)
      @mean = (data.inject(0) {|i,j| i += j}) / data.size
    end

    ##
    # Computes mode and generates a histogram (for free!). 
    # (We needed it anyway).
    def mode
      @hist     ||= {}
      @max_freq ||= 0
      @mode     ||= nil
      unless @mode
        @data.each do |val|
          @hist[val] ||= 0
          @hist[val] += 1
          @max_freq, @mode = @hist[val], val if @hist[val] > @max_freq
        end
      end
      @mode
    end

    ##
    # Computes variance. Used to measure degree of spread 
    # in dataset.
    def variance
      @variance ||= 
        @data.inject(0) { |i,j| i += (j - mean(@data)) ** 2}  / (@data.size - 1)
    end

    ##
    # Standard deviation. Square root of variance, measure of the
    # spread of the data about the mean.
    def std_dev
      @std_dev ||= Math.sqrt(variance)
    end

    ##
    # Geometric mean. Only applies to non-negative numbers, and
    # relates to log-normal distribution.
    def geometric_mean
      if @data.any? { |x| x < 0 }
        raise "Geometric mean only applies to non-negative data"
      end

      @geometric_mean ||= 
        2 ** (mean @data.map { |x| Math.log2(x) })
        # this overflowed for dataset with large numbers
        # (@data.inject(1) {|i,j| i *= j})**(1.0/@data.size)
    end

    ##
    # Harmonic or subcontrary mean. Tends strongly toward the least
    # elements of the dataset.
    def harmonic_mean
      @harmonic_mean ||=
        @data.size.to_f / (@data.inject(0) {|i,j| i += (1.0/j)})
    end

    ##
    # Put the histogram into a string if we have it
    def hist
      if defined? @hist
        # this is a textbook example of how to lie with statistics...
        # TODO: iterate over a range rather than @hist.keys--a histogram
        # produced out of the keys won't properly represent flat spots
        # with no data. or something like that. do as i say, not as i do.
        #
        # this code borrows liberally from the ruby cookbook, recipe 5.12
        # ORA, 2006
        pairs = @hist.keys.map { |x| [x.to_s, @hist[x]] }.sort
        largest_key_size = pairs.max { |x,y| x[0].size <=> y[0].size }[0].size
        pairs.inject("") do |s,kv|
        s<< "#{kv[0].ljust(largest_key_size)} |#{char*kv[1]}\n"
      end
      end
    end

    # Return a string with statisical info about a dataset.
    def to_s
      <<-DATA_STR    
        Partition:#{partition(median).inspect} 
        Mean:#{mean}
        Geometric Mean:#{geometric_mean}
        Harmonic Mean:#{harmonic_mean}
        Median:#{median} 
        Min:#{data.min} 
        Q1:#{q1}
        Q3:#{q3}
        Max:#{data.max}
        IQR:#{iqr}
        Outliers:#{outliers.inspect}
        Variance:#{variance} 
        Std Dev:#{std_dev}
      DATA_STR
    end
  end  
end
