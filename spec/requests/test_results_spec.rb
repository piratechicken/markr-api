require 'rails_helper'

RSpec.describe '/test_results', type: :request do
  let(:valid_headers) { { 'Content-Type': 'text/xml+markr' } }

  describe 'POST /import' do
    context 'with a valid xml body' do
      it 'creates three new TestResults' do
        expect do
          post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)
        end.to change(TestResult, :count).by(3)
      end

      it 'renders a JSON response with the new test_result' do
        post('/import', params: xml_fixture('simple_test_results'), headers: valid_headers)

        expect(response).to have_http_status(:created)
      end
    end

    # context 'with an unexpected Content-Type header' do
    #   it 'does not create any new TestResults' do
    #     pending
    #   end

    #   it 'renders a JSON response with expected errors' do
    #     pending
    #   end
    # end

    # context 'with an unexpected xml body' do
    #   it 'does not create any new TestResults' do
    #     pending
    #   end

    #   it 'renders a JSON response with expected errors' do
    #     pending
    #   end
    # end

    # context 'with a higher test mark for a test result that already exists' do
    #   it 'updates the test result to the higher mark' do
    #     pending
    #   end

    #   it 'renders a JSON response with errors for the new test_result' do
    #     pending
    #   end
    # end

    # context 'with a lower test mark for a test result that already exists' do
    #   it 'does not update the test result (leaving it at the higher mark' do
    #     pending
    #   end

    #   it 'renders a JSON response with errors for the new test_result' do
    #     pending
    #   end
    # end
  end
end
