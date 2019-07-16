# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181027045932) do

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "drivers", force: :cascade do |t|
    t.integer "year"
    t.string "name"
    t.string "abbr_name"
    t.integer "car_number"
    t.string "team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leaderboards", force: :cascade do |t|
    t.integer "year"
    t.integer "total_points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_leaderboards_on_user_id"
  end

  create_table "points", force: :cascade do |t|
    t.string "item"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quali_position"
    t.integer "race_position"
  end

  create_table "quali_results", force: :cascade do |t|
    t.integer "position"
    t.integer "driver_id"
    t.integer "race_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "race_results", force: :cascade do |t|
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "race_id"
    t.bigint "driver_id"
    t.index ["driver_id"], name: "index_race_results_on_driver_id"
    t.index ["race_id"], name: "index_race_results_on_race_id"
  end

  create_table "races", force: :cascade do |t|
    t.integer "year"
    t.integer "race_number"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ical_uid"
    t.datetime "ical_dtstart"
    t.string "ical_summary"
    t.string "img"
    t.string "ergast_country"
  end

  create_table "tips", force: :cascade do |t|
    t.string "qual_first"
    t.string "qual_second"
    t.string "qual_third"
    t.string "race_first"
    t.string "race_second"
    t.string "race_third"
    t.string "race_tenth"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "race_id"
    t.string "updated_by"
    t.integer "qual_first_points"
    t.integer "qual_second_points"
    t.integer "qual_third_points"
    t.integer "race_first_points"
    t.integer "race_second_points"
    t.integer "race_third_points"
    t.integer "race_tenth_points"
    t.integer "race_total_points"
    t.index ["race_id"], name: "index_tips_on_race_id"
    t.index ["user_id"], name: "index_tips_on_user_id"
  end

  create_table "tracks", force: :cascade do |t|
    t.string "country"
    t.string "circuit"
    t.integer "laps"
    t.string "svg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "userdata", force: :cascade do |t|
    t.string "user_id"
    t.string "season"
    t.integer "fee_paid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "admin", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "approved", default: false, null: false
    t.index ["approved"], name: "index_users_on_approved"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
