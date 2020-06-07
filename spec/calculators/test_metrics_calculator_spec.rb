require 'rails_helper'

RSpec.describe TestMetricsCalculator, type: :model do
  subject { described_class.new(test_result_array: test_results) }

  let(:test_results) { [15.0, 100.0, 90.0, 53.3, 80.0, 83.7, 88.3, 48.4, 60.6, 62.9, 51.4] }

  describe '#metrics' do
    it 'returns the correct summary metrics in a hash' do
      expect(subject.metrics).to eq(expected_metrics)
    end
  end

  private

    def expected_metrics
      {
        count: 11,
        max: 100.0,
        mean: 66.7,
        min: 15.0,
        p25: 51.4,
        p50: 62.9,
        p75: 88.3,
        stddev: 24.6
      }
    end
end
