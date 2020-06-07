class TestSummaryMetrics

  attr_reader :test_result_array

  def initialize(test_result_array: test_result_array)
    @test_result_array = test_result_array
  end

  def metrics
    {
      mean: mean.round(1),
      stddev: standard_deviation.round(1),
      min: test_result_array.min.round(1),
      max: test_result_array.max.round(1),
      p25: calculate_percentile(25).round(1),
      p50: calculate_percentile(50).round(1),
      p75: calculate_percentile(75).round(1),
      count: count.round(1)
    }
  end

  private

    def count
      @count ||= test_result_array.count
    end

    def sum
      test_result_array.sum
    end

    def mean
      @mean ||= (sum / count)
    end

    def standard_deviation
      squared_diff = test_result_array.map { |mark| (mark - mean)**2 }
      sum_of_squares = squared_diff.sum

      Math.sqrt(sum_of_squares / (count - 1))
    end

    def ordered_results
      @ordered_results ||= test_result_array.sort
    end

    def calculate_percentile(percentile)
      # Nearest rank method
      # Can floor rank as using for array index
      index_rank = (percentile / 100.0 * count).to_i

      ordered_results[index_rank]
    end

end
