require 'rubygems'
require 'minitest/autorun'
require 'ministat'

class TestMiniStat < MiniTest::Unit::TestCase
  def setup
    @data1 = [34, 47, 1, 15, 57, 24, 20, 11, 19, 50, 28, 37]
    @data2 = [60, 56, 61, 68, 51, 53, 69, 54]                  
    @data3 = File.open('test/data/1.dat').map { |l| l.chomp }
    @data4 = File.open('test/data/2.dat').map { |l| l.chomp }
    @data5 = File.open('test/data/3.dat').map { |l| l.chomp }
    @ms1   = MiniStat::Data.new(@data1)
    @ms2   = MiniStat::Data.new(@data2)
    @ms3   = MiniStat::Data.new(@data3)
    @ms4   = MiniStat::Data.new(@data4)
    @ms5   = MiniStat::Data.new(@data5)
  end

  def test_enum
    ms = MiniStat::Data.new([1])
    assert ms.mean == 1
    ms << 2 
    assert ms.mean == 1.5
  end

  ##
  # Expected test values are computed in a 3rd party statistics
  # package (usually R) when possible.
  #
  # All the basic tests do a dummy check of adding a value to the data
  # set and ensuring the the values are re-computed.

  def test_iqr
    assert_in_delta 25, @ms1.iqr
    assert_in_delta 11, @ms2.iqr
    assert_in_delta 1.94, @ms3.iqr
    assert_in_delta 9.15, @ms4.iqr
    assert_in_delta 4677, @ms5.iqr
    
    @ms1 << 32
    assert_in_delta 25, @ms1.iqr
  end                                                   

  def test_mean
    assert_in_delta 28.583, @ms1.mean
    assert_in_delta 59, @ms2.mean
    assert_in_delta 2.179, @ms3.mean
    assert_in_delta 1.878, @ms4.mean
    assert_in_delta 4884.695, @ms5.mean

    @ms1 << 32
    assert_in_delta 28.84615, @ms1.mean
  end

  def test_median
    assert_in_delta 26, @ms1.median
    assert_in_delta 58, @ms2.median
    assert_in_delta 1.735, @ms3.median
    assert_in_delta 2.8, @ms4.median
    assert_in_delta 5016, @ms5.median
    
    @ms1 << 32
    assert_in_delta 28, @ms1.median
  end

  def test_mode
    ms = MiniStat::Data.new([1,1,1,2,3,4,5])
    assert_equal(ms.mode, 1)
    ms = MiniStat::Data.new([1,2,2,2,2,3,4,5])
    assert_equal(ms.mode, 2)
  end

  def test_outliers
    assert_equal @ms1.outliers, []
    assert_includes @ms3.outliers, 6.0

    @ms1 << 1000
    assert_includes @ms1.outliers, 1000
  end

  def test_q1
    assert_in_delta 17, @ms1.q1
    assert_in_delta 53.5, @ms2.q1
    assert_in_delta 1.05, @ms3.q1
    assert_in_delta(-2.4, @ms4.q1)
    assert_in_delta 2442, @ms5.q1

    # add below our initial q1 to skew the result
    @ms1 << 1
    assert_in_delta 13, @ms1.q1
  end

  def test_q3
    assert_in_delta 42, @ms1.q3
    assert_in_delta 64.5, @ms2.q3
    assert_in_delta 2.99, @ms3.q3
    assert_in_delta 6.75, @ms4.q3
    assert_in_delta 7119, @ms5.q3

    # add above our initial q3 to skew the result
    @ms1 << 100
    assert_in_delta 48.5, @ms1.q3
  end

  def test_variance
    assert_in_delta 286.0833, @ms1.variance
    assert_in_delta 45.71429, @ms2.variance
    assert_in_delta 2.297878, @ms3.variance
    assert_in_delta 57.06196, @ms4.variance
    assert_in_delta 8376067, @ms5.variance, 1
    
    @ms1 << 32
    assert_in_delta 263.141, @ms1.variance
  end

  def test_std_dev
    assert_in_delta 16.914, @ms1.std_dev
    assert_in_delta 6.761, @ms2.std_dev
    assert_in_delta 1.515, @ms3.std_dev
    assert_in_delta 7.553, @ms4.std_dev
    assert_in_delta 2894.144, @ms5.std_dev

    @ms1 << 32
    assert_in_delta 16.22162, @ms1.std_dev
  end

  def test_geo_mean
    assert_in_delta 58.66896, @ms2.geometric_mean
    assert_in_delta 1.695651, @ms3.geometric_mean
    # @ms4 contains negative numbers, so we should complain
    assert_raises RuntimeError do 
      @ms4.geometric_mean
    end
    assert_in_delta 3463.229, @ms5.geometric_mean

    @ms1 << 32
    assert_in_delta 21.63259, @ms1.geometric_mean
  end

  def test_harm_mean
    assert_in_delta 8.259642, @ms1.harmonic_mean
    assert_in_delta 58.34724, @ms2.harmonic_mean
    assert_in_delta 1.218216, @ms3.harmonic_mean
    assert_in_delta 5.921447, @ms4.harmonic_mean
    assert_in_delta 976.2331, @ms5.harmonic_mean

    @ms1 << 32
    assert_in_delta 8.759532, @ms1.harmonic_mean
  end

end
