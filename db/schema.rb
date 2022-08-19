# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_08_19_191454) do
  create_table "appearances", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "voter_id"
    t.integer "site_id"
    t.integer "prompt_id"
    t.integer "question_id"
    t.string "lookup"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "answerable_id"
    t.string "answerable_type"
    t.boolean "valid_record", default: true
    t.string "validity_information"
    t.string "algorithm_name"
    t.text "algorithm_metadata"
    t.index ["answerable_id", "answerable_type"], name: "index_appearances_on_answerable_id_and_answerable_type"
    t.index ["lookup"], name: "index_appearances_on_lookup"
    t.index ["prompt_id"], name: "index_appearances_on_prompt_id"
    t.index ["question_id", "voter_id"], name: "index_appearances_on_question_id_voter_id"
  end

  create_table "choice_versions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "choice_id"
    t.integer "version"
    t.integer "item_id"
    t.integer "question_id"
    t.integer "position"
    t.integer "ratings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "request_id"
    t.integer "prompt_id"
    t.boolean "active", default: false
    t.text "tracking"
    t.float "score"
    t.string "local_identifier"
    t.integer "prompts_on_the_left_count", default: 0
    t.integer "prompts_on_the_right_count", default: 0
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.integer "prompts_count", default: 0
    t.string "data"
    t.integer "creator_id"
    t.index ["choice_id"], name: "index_choice_versions_on_choice_id"
  end

  create_table "choices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "item_id"
    t.integer "question_id"
    t.integer "position"
    t.integer "ratings"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "request_id"
    t.integer "prompt_id"
    t.boolean "active", default: false
    t.text "tracking"
    t.float "score"
    t.string "local_identifier"
    t.integer "prompts_on_the_left_count", default: 0
    t.integer "prompts_on_the_right_count", default: 0
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.integer "prompts_count", default: 0
    t.string "data"
    t.integer "creator_id"
    t.integer "version"
    t.index ["creator_id"], name: "index_choices_on_creator_id"
    t.index ["question_id", "score"], name: "index_choices_on_question_id_and_score"
  end

  create_table "clicks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "site_id"
    t.integer "visitor_id"
    t.text "additional_info"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "what_was_clicked"
  end

  create_table "delayed_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "densities", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "question_id"
    t.float "value"
    t.string "prompt_type", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exports", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", default: ""
    t.integer "question_id"
    t.binary "data", size: :long
    t.boolean "compressed", default: false
    t.index ["name"], name: "index_exports_on_name"
  end

  create_table "flags", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "explanation", default: ""
    t.integer "visitor_id"
    t.integer "choice_id"
    t.integer "question_id"
    t.integer "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "old_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "data"
    t.boolean "active"
    t.text "tracking"
    t.integer "creator_id"
    t.integer "voter_id"
    t.integer "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "question_id"
    t.index ["creator_id"], name: "index_items_on_creator_id"
  end

  create_table "oldskips", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "skipper_id"
    t.integer "prompt_id"
    t.text "tracking"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oldvotes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "tracking"
    t.integer "site_id"
    t.integer "voter_id"
    t.integer "voteable_id"
    t.string "voteable_type", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prompts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "question_id"
    t.integer "left_choice_id"
    t.integer "right_choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "tracking"
    t.integer "votes_count", default: 0
    t.index ["left_choice_id", "right_choice_id", "question_id"], name: "a_cool_index", unique: true
    t.index ["left_choice_id"], name: "index_prompts_on_left_choice_id"
    t.index ["question_id"], name: "index_prompts_on_question_id"
    t.index ["right_choice_id"], name: "index_prompts_on_right_choice_id"
  end

  create_table "question_versions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "question_id"
    t.integer "version"
    t.integer "creator_id"
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "choices_count", default: 0
    t.integer "prompts_count", default: 0
    t.boolean "active", default: false
    t.text "tracking"
    t.text "information"
    t.integer "site_id"
    t.string "local_identifier"
    t.integer "votes_count", default: 0
    t.boolean "it_should_autoactivate_ideas", default: false
    t.integer "inactive_choices_count", default: 0
    t.boolean "uses_catchup", default: true
    t.boolean "show_results", default: true
    t.index ["question_id"], name: "index_question_versions_on_question_id"
  end

  create_table "questions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "creator_id"
    t.string "name", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "choices_count", default: 0
    t.integer "prompts_count", default: 0
    t.boolean "active", default: false
    t.text "tracking"
    t.text "information"
    t.integer "site_id"
    t.string "local_identifier"
    t.integer "votes_count", default: 0
    t.boolean "it_should_autoactivate_ideas", default: false
    t.integer "inactive_choices_count", default: 0
    t.boolean "uses_catchup", default: true
    t.boolean "show_results", default: true
    t.integer "version"
  end

  create_table "skips", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "tracking"
    t.integer "site_id"
    t.integer "skipper_id"
    t.integer "question_id"
    t.integer "prompt_id"
    t.integer "appearance_id"
    t.integer "time_viewed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "skip_reason"
    t.string "missing_response_time_exp", default: ""
    t.boolean "valid_record", default: true
    t.string "validity_information"
    t.index ["prompt_id"], name: "index_skips_on_prompt_id"
    t.index ["question_id"], name: "index_skips_on_question_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email"
    t.string "encrypted_password", limit: 128
    t.string "salt", limit: 128
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128
    t.boolean "email_confirmed", default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email"
    t.index ["id", "confirmation_token"], name: "index_users_on_id_and_confirmation_token"
    t.index ["remember_token"], name: "index_users_on_remember_token"
  end

  create_table "visitors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "site_id"
    t.string "identifier", default: ""
    t.text "tracking"
    t.boolean "activated"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["identifier", "site_id"], name: "index_visitors_on_identifier_and_site_id", unique: true
  end

  create_table "votes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "tracking"
    t.integer "site_id"
    t.integer "voter_id"
    t.integer "question_id"
    t.integer "prompt_id"
    t.integer "choice_id"
    t.integer "loser_choice_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "time_viewed"
    t.integer "appearance_id"
    t.string "missing_response_time_exp", default: ""
    t.boolean "valid_record", default: true
    t.string "validity_information"
    t.index ["choice_id"], name: "choice_id_idx"
    t.index ["created_at", "question_id"], name: "index_votes_on_created_at_and_question_id"
    t.index ["loser_choice_id"], name: "loser_choice_id_idx"
    t.index ["question_id"], name: "question_id_idx"
    t.index ["voter_id"], name: "index_votes_on_voter_id"
  end

end
