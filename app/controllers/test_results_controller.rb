class TestResultsController < ApplicationController

  prepend_before_action :validate_import, only: [:import]

  def import
    imported_test_results = import_as_hash.dig(:mcq_test_results, :mcq_test_result)

    TestResult.transaction do
      imported_test_results.each do |incoming_test_data|
        test_result_record = TestResult.find_or_initialize_by(
          test_id: incoming_test_data[:test_id],
          student_number: incoming_test_data[:student_number]
        )
        test_result_record.assign_attributes(parse_test_result(incoming_test_data, test_result_record))
        test_result_record.save!
      end
    end

    render(status: :created)
  rescue ActiveRecord::RecordInvalid => e
    errors_hash = {
      student_number: e.record.student_number,
      test_id: e.record.test_id,
      errors: e.record.errors
    }
    render(json: errors_hash, status: :unprocessable_entity)
  end

  def aggregate
    test_results = TestResult.where(test_id: params[:test_id])

    render(status: :not_found) && return if test_results.blank?

    results_as_percentage = test_results.map(&:mark_as_percentage)

    count = results_as_percentage.count
    sum = results_as_percentage.sum
    min = results_as_percentage.min
    max = results_as_percentage.max

    mean = sum / count

    sum_of_squares = results_as_percentage.map { |mark| (mark - mean)**2 }.sum
    stddev = Math.sqrt(sum_of_squares / (count - 1))

    ordered_results = results_as_percentage.sort
    p25 = ordered_results[calculate_percentile_index(25, count)]
    p50 = ordered_results[calculate_percentile_index(50, count)]
    p75 = ordered_results[calculate_percentile_index(75, count)]

    render(
      json: {
        mean: mean.round(1),
        stddev: stddev.round(1),
        min: min.round(1),
        max: max.round(1),
        p25: p25.round(1),
        p50: p50.round(1),
        p75: p75.round(1),
        count: count.round(1)
      },
      status: :ok
    )
  end

  private

    def parse_test_result(incoming_test_data, test_result_record)
      new_marks_obtained = incoming_test_data.dig(:summary_marks, :obtained)&.to_i
      {
        student_first_name: incoming_test_data[:first_name],
        student_last_name: incoming_test_data[:last_name],
        marks_available: incoming_test_data.dig(:summary_marks, :available)&.to_i,
        marks_obtained: [new_marks_obtained, test_result_record.marks_obtained].compact.max
      }
    end

    def validate_import
      valid_request_header = request.headers['Content-Type'] == 'text/xml+markr'
      valid_body = import_as_hash.key?(:mcq_test_results)

      return if valid_request_header && valid_body

      render(json: { error: 'Invalid request' }, status: :unprocessable_entity)
    end

    def import_as_hash
      @import_as_hash ||= Hash.from_xml(request.body.read).with_indifferent_access
    end

    def calculate_percentile_index(percentile, count)
      # Can floor rank as using for array index
      (percentile / 100.0 * count).to_i
    end

end
