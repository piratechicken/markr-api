class TestResultsController < ApplicationController

  def import
    body_as_hash = Hash.from_xml(request.body.read).with_indifferent_access
    test_results = body_as_hash.dig(:mcq_test_results, :mcq_test_result)

    TestResult.transaction do
      test_results.each do |test_result|
        TestResult.create!(parse_test_result(test_result))
      end
    end

    render(status: :created)
  rescue ActiveRecord::RecordInvalid
    render(status: :unprocessable_entity)
  end

  def parse_test_result(test_result)
    {
      test_id: test_result[:test_id],
      student_number: test_result[:student_number],
      student_first_name: test_result[:first_name],
      student_last_name: test_result[:last_name],
      marks_available: test_result.dig(:summary_marks, :available)&.to_i,
      marks_obtained: test_result.dig(:summary_marks, :obtained)&.to_i
    }
  end

end
