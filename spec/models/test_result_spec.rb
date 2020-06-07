require 'rails_helper'

RSpec.describe TestResult, type: :model do
  describe 'uniqueness' do
    before { create(:test_result) }

    it { is_expected.to validate_uniqueness_of(:student_number).scoped_to(:test_id) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:test_id) }
    it { is_expected.to validate_presence_of(:student_number) }
    it { is_expected.to validate_presence_of(:student_first_name) }
    it { is_expected.to validate_presence_of(:student_last_name) }
    it { is_expected.to validate_presence_of(:marks_available) }
    it { is_expected.to validate_presence_of(:marks_obtained) }
  end
end
