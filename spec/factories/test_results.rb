FactoryBot.define do
  factory :test_result do
    test_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    student_number { Faker::Alphanumeric.alphanumeric(number: 10) }
    student_first_name { Faker::Name.first_name }
    student_last_name { Faker::Name.last_name }
    marks_available { 10 }
    marks_obtained { rand(0..10) }
  end
end
