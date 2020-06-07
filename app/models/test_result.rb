class TestResult < ApplicationRecord

  validates :test_id, presence: true
  validates :student_number, presence: true,  uniqueness: { scope: :test_id }
  validates :student_first_name, presence: true
  validates :student_last_name, presence: true
  validates :marks_available, presence: true
  validates :marks_obtained, presence: true

end
