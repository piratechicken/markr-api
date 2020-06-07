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

      it 'renders a JSON response with the new test_result' do
        post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)

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
        expect(JSON.parse(response.body)).to eq('error' => 'Invalid request')
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
        expect(JSON.parse(response.body)).to eq('error' => 'Invalid request')
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
  end
end
