class CreateTestResults < ActiveRecord::Migration[6.0]

  def change
    create_table :test_results do |t|
      t.string :student_number, null: false
      t.string :student_first_name, null: false
      t.string :student_last_name, null: false
      t.string :test_id, null: false, index: true
      t.integer :marks_available, null: false
      t.integer :marks_obtained, null: false

      t.timestamps
    end

    add_index :test_results, [:test_id, :student_number], name: 'index_test_results_on_test_id_and_student_number', unique: true
  end

end
