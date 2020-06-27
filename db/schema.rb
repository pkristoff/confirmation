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

ActiveRecord::Schema.define(version: 2020_06_17_080358) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "street_1", default: "", null: false
    t.string "street_2", default: "", null: false
    t.string "city", default: "", null: false
    t.string "state", default: "", null: false
    t.string "zip_code", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admins", id: :serial, force: :cascade do |t|
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
    t.string "name", default: "", null: false
    t.string "contact_name", default: "", null: false
    t.string "contact_phone", default: "", null: false
    t.string "account_name", default: "Admin", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["name"], name: "index_admins_on_name", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "baptismal_certificates", id: :serial, force: :cascade do |t|
    t.date "birth_date"
    t.date "baptismal_date"
    t.string "church_name"
    t.string "father_first"
    t.string "father_last"
    t.string "father_middle"
    t.string "mother_first"
    t.string "mother_middle"
    t.string "mother_maiden"
    t.string "mother_last"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "church_address_id"
    t.integer "scanned_certificate_id"
    t.boolean "first_comm_at_home_parish", default: false, null: false
    t.boolean "baptized_at_home_parish", default: false, null: false
    t.integer "show_empty_radio", default: 0, null: false
    t.index ["church_address_id"], name: "index_baptismal_certificates_on_church_address_id"
    t.index ["scanned_certificate_id"], name: "index_baptismal_certificates_on_scanned_certificate_id"
  end

  create_table "candidate_events", id: :serial, force: :cascade do |t|
    t.date "completed_date"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "candidate_id"
    t.index ["candidate_id"], name: "index_candidate_events_on_candidate_id"
  end

  create_table "candidate_sheets", id: :serial, force: :cascade do |t|
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.decimal "grade", precision: 2, default: "10", null: false
    t.string "candidate_email", default: "", null: false
    t.string "parent_email_1", default: "", null: false
    t.string "parent_email_2", default: "", null: false
    t.string "attending", default: "The Way", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "address_id"
    t.string "middle_name", default: "", null: false
    t.decimal "program_year", precision: 1, default: "2", null: false
    t.index ["address_id"], name: "index_candidate_sheets_on_address_id"
  end

  create_table "candidates", id: :serial, force: :cascade do |t|
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
    t.string "account_name", default: "", null: false
    t.boolean "signed_agreement", default: false, null: false
    t.integer "baptismal_certificate_id"
    t.integer "sponsor_covenant_id"
    t.integer "pick_confirmation_name_id"
    t.integer "christian_ministry_id"
    t.integer "candidate_sheet_id"
    t.integer "retreat_verification_id"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text "candidate_note", default: "", null: false
    t.integer "sponsor_eligibility_id"
    t.index ["account_name"], name: "index_candidates_on_account_name", unique: true
    t.index ["baptismal_certificate_id"], name: "index_candidates_on_baptismal_certificate_id"
    t.index ["candidate_sheet_id"], name: "index_candidates_on_candidate_sheet_id"
    t.index ["christian_ministry_id"], name: "index_candidates_on_christian_ministry_id"
    t.index ["confirmation_token"], name: "index_candidates_on_confirmation_token", unique: true
    t.index ["pick_confirmation_name_id"], name: "index_candidates_on_pick_confirmation_name_id"
    t.index ["reset_password_token"], name: "index_candidates_on_reset_password_token", unique: true
    t.index ["retreat_verification_id"], name: "index_candidates_on_retreat_verification_id"
    t.index ["sponsor_covenant_id"], name: "index_candidates_on_sponsor_covenant_id"
    t.index ["sponsor_eligibility_id"], name: "index_candidates_on_sponsor_eligibility_id"
  end

  create_table "christian_ministries", id: :serial, force: :cascade do |t|
    t.text "what_service"
    t.text "where_service"
    t.text "when_service"
    t.text "helped_me"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "confirmation_events", id: :serial, force: :cascade do |t|
    t.string "event_key"
    t.date "the_way_due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "instructions", default: "", null: false
    t.date "chs_due_date"
    t.index ["event_key"], name: "index_confirmation_events_on_event_key"
  end

  create_table "pick_confirmation_names", id: :serial, force: :cascade do |t|
    t.string "saint_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "retreat_verifications", id: :serial, force: :cascade do |t|
    t.boolean "retreat_held_at_home_parish", default: false, null: false
    t.date "start_date"
    t.date "end_date"
    t.string "who_held_retreat"
    t.string "where_held_retreat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "scanned_retreat_id"
    t.index ["scanned_retreat_id"], name: "index_retreat_verifications_on_scanned_retreat_id"
  end

  create_table "scanned_images", id: :serial, force: :cascade do |t|
    t.string "filename"
    t.string "content_type"
    t.binary "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sponsor_covenants", id: :serial, force: :cascade do |t|
    t.string "sponsor_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "scanned_covenant_id"
    t.index ["scanned_covenant_id"], name: "index_sponsor_covenants_on_scanned_covenant_id"
  end

  create_table "sponsor_eligibilities", force: :cascade do |t|
    t.boolean "sponsor_attends_home_parish", default: true, null: false
    t.string "sponsor_church", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "scanned_eligibility_id"
    t.index ["scanned_eligibility_id"], name: "index_sponsor_eligibilities_on_scanned_eligibility_id"
  end

  create_table "to_dos", id: :serial, force: :cascade do |t|
    t.integer "confirmation_event_id"
    t.integer "candidate_event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_event_id"], name: "index_to_dos_on_candidate_event_id"
    t.index ["confirmation_event_id"], name: "index_to_dos_on_confirmation_event_id"
  end

  create_table "visitors", force: :cascade do |t|
    t.text "home", default: "", null: false
    t.text "about", default: "", null: false
    t.text "contact", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "home_parish"
  end

  add_foreign_key "candidates", "baptismal_certificates"
  add_foreign_key "candidates", "candidate_sheets"
  add_foreign_key "candidates", "christian_ministries"
  add_foreign_key "candidates", "pick_confirmation_names"
  add_foreign_key "candidates", "retreat_verifications"
  add_foreign_key "candidates", "sponsor_covenants"
  add_foreign_key "candidates", "sponsor_eligibilities"
end
