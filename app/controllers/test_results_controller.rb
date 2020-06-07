class TestResultsController < ApplicationController

  prepend_before_action :validate_import, only: [:import]

  def import
    imported_test_results = import_as_hash.dig(:mcq_test_results, :mcq_test_result)

    TestResult.transaction do
      imported_test_results.each do |incoming_test_data|
        generate_test_result(incoming_test_data)
      end
    end

    render(status: :created)
  rescue ActiveRecord::RecordInvalid => e
    render(json: validation_errors_to_hash(e), status: :unprocessable_entity)
  end

  def aggregate
    test_results = TestResult.where(test_id: params[:test_id])

    render(status: :not_found) && return if test_results.blank?

    results_as_percentage = test_results.map(&:mark_as_percentage)
    summary_metrics = ::TestMetricsCalculator.new(test_result_array: results_as_percentage)

    render(json: summary_metrics.metrics, status: :ok)
  end

  private

    def generate_test_result(incoming_test_data)
      test_result_record = TestResult.find_or_initialize_by(
        test_id: incoming_test_data[:test_id],
        student_number: incoming_test_data[:student_number]
      )
      test_result_record.assign_attributes(parse_test_result(incoming_test_data, test_result_record))
      test_result_record.save!
    end

    def parse_test_result(incoming_test_data, test_result_record)
      new_marks_obtained = incoming_test_data.dig(:summary_marks, :obtained)&.to_i
      new_marks_available = incoming_test_data.dig(:summary_marks, :available)&.to_i
      {
        student_first_name: incoming_test_data[:first_name],
        student_last_name: incoming_test_data[:last_name],
        marks_available: [new_marks_available, test_result_record.marks_available].compact.max,
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

    def validation_errors_to_hash(error)
      {
        student_number: error.record.student_number,
        test_id: error.record.test_id,
        errors: error.record.errors
      }
    end

end
