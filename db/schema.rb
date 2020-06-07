# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_07_002445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "test_results", force: :cascade do |t|
    t.string "student_number", null: false
    t.string "student_first_name", null: false
    t.string "student_last_name", null: false
    t.string "test_id", null: false
    t.integer "marks_available", null: false
    t.integer "marks_obtained", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["test_id", "student_number"], name: "index_test_results_on_test_id_and_student_number", unique: true
    t.index ["test_id"], name: "index_test_results_on_test_id"
  end

end
