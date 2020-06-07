require 'rails_helper'

RSpec.describe '/test_results', type: :request do
  let(:valid_headers) { { 'Content-Type': 'text/xml+markr' } }

  describe 'POST /import' do
    context 'with a valid xml body' do
      it 'creates three new TestResults' do
        expect do
          post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)

          expect(TestResult.all.pluck(:marks_obtained).sort).to eq([9, 10, 13])
        end.to change(TestResult, :count).by(3)
      end

      it 'renders status: 201' do
        post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with the provided example xml data' do
      it 'creates 81 new TestResults' do
        expect do
          post('/import', params: xml_fixture('example_test_results'), headers: valid_headers)
          expect(
            # Duplicated result in import takes the higher mark
            TestResult.find_by(student_number: 2306, test_id: 9863).marks_obtained
          ).to eq(13)
        end.to change(TestResult, :count).by(81)
      end

      it 'renders status: 201' do
        post('/import', params: xml_fixture('example_test_results'), headers: valid_headers)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with an unexpected Content-Type header' do
      let(:invalid_headers) { { 'Content-Type': 'text/xml' } }

      it 'does not create any new TestResults' do
        expect do
          post('/import', params: xml_fixture('simple_test_results'), headers: invalid_headers)
        end.to change(TestResult, :count).by(0)
      end

      it 'renders a JSON response with expected errors' do
        post('/import', params: xml_fixture('simple_test_results'), headers: invalid_headers)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body(response)).to eq(error: 'Invalid request')
      end
    end

    context 'with an unexpected initial xml key' do
      it 'does not create any new TestResults' do
        expect do
          post('/import', params: xml_fixture('test_result_invalid_key'), headers: valid_headers)
        end.to change(TestResult, :count).by(0)
      end

      it 'renders a JSON response with expected errors' do
        post('/import', params: xml_fixture('test_result_invalid_key'), headers: valid_headers)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body(response)).to eq(error: 'Invalid request')
      end
    end

    context 'with a higher test mark for a test result that already exists' do
      before do
        create(:test_result, student_number: 52158351281, test_id: 1234, marks_obtained: 1)
      end

      it 'updates the test record with the higher mark' do
        post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)

        expect(
          TestResult.find_by(student_number: 52158351281, test_id: 1234).marks_obtained
        ).to eq(13)
      end

      it 'only creates two new records' do
        expect do
          post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)
        end.to change(TestResult, :count).by(2)
      end
    end

    context 'with a LOWER test mark for a test result that already exists' do
      before do
        create(:test_result, student_number: 52158351281, test_id: 1234, marks_obtained: 20)
      end

      it 'keeps the existing higher mark' do
        post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)

        expect(
          TestResult.find_by(student_number: 52158351281, test_id: 1234).marks_obtained
        ).to eq(20)
      end
    end

    context 'with an invalid set of test results (missing require attributes)' do
      it 'does not create any incoming test results (rejects entire payload)' do
        expect do
          post('/import', params: xml_fixture('simple_invalid_results'), headers: valid_headers)
        end.to change(TestResult, :count).by(0)
      end

      it 'renders a JSON response with expected errors' do
        post('/import', params: xml_fixture('simple_invalid_results'), headers: valid_headers)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body(response)).to eq(expected_validation_errors)
      end
    end
  end

  describe 'GET results/:test_id/aggregate' do
    before do
      create(:test_result, test_id: 123, marks_available: 20, marks_obtained: 3)
      create(:test_result, test_id: 123, marks_available: 20, marks_obtained: 20)
      create(:test_result, test_id: 123, marks_available: 10, marks_obtained: 9)
      create(:test_result, test_id: 123, marks_available: 30, marks_obtained: 16)
      create(:test_result, test_id: 123, marks_available: 25, marks_obtained: 20)
    end

    context 'with a valid xml body' do
      it 'renders a JSON response with correct test metrics' do
        get('/results/123/aggregate')

        expect(response).to have_http_status(:ok)
        expect(parsed_body(response)).to eq(expected_aggregate_body)
      end
    end

    context 'when there is no test data' do
      it 'renders status 404' do
        get('/results/124/aggregate')

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  private

    def expected_validation_errors
      {
        student_number: '5215851283',
        test_id: '1234',
        errors: {
          marks_obtained: ["can't be blank"],
          student_first_name: ["can't be blank"],
          student_last_name: ["can't be blank"]
        }
      }
    end

    def expected_aggregate_body
      {
        mean: 67.7,
        stddev: 34.2,
        min: 15.0,
        max: 100.0,
        p25: 53.3,
        p50: 80.0,
        p75: 90.0,
        count: 5
      }
    end

    def parsed_body(response)
      JSON.parse(response.body, symbolize_names: true)
    end
end
