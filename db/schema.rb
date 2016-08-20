# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160820010320) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "street_1",   default: "",      null: false
    t.string   "street_2",   default: "",      null: false
    t.string   "city",       default: "Apex",  null: false
    t.string   "state",      default: "NC",    null: false
    t.string   "zip_code",   default: "27502", null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name",                   default: "", null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["name"], name: "index_admins_on_name", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "baptismal_certificates", force: :cascade do |t|
    t.date     "birth_date"
    t.date     "baptismal_date"
    t.string   "church_name"
    t.string   "father_first"
    t.string   "father_last"
    t.string   "father_middle"
    t.string   "mother_first"
    t.string   "mother_middle"
    t.string   "mother_maiden"
    t.string   "mother_last"
    t.string   "certificate_filename"
    t.string   "certificate_content_type"
    t.binary   "certificate_file_contents"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "church_address_id"
  end

  add_index "baptismal_certificates", ["church_address_id"], name: "index_baptismal_certificates_on_church_address_id", using: :btree

  create_table "candidate_events", force: :cascade do |t|
    t.date     "completed_date"
    t.boolean  "verified"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "candidate_id"
  end

  add_index "candidate_events", ["candidate_id"], name: "index_candidate_events_on_candidate_id", using: :btree

  create_table "candidates", force: :cascade do |t|
    t.string   "parent_email_1",                         default: "",        null: false
    t.string   "encrypted_password",                     default: "",        null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                          default: 0,         null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.string   "account_name",                           default: "",        null: false
    t.string   "first_name",                             default: "",        null: false
    t.string   "last_name",                              default: "",        null: false
    t.decimal  "grade",                    precision: 2, default: 10,        null: false
    t.string   "candidate_email",                        default: "",        null: false
    t.string   "parent_email_2",                         default: "",        null: false
    t.string   "attending",                              default: "The Way", null: false
    t.integer  "address_id",                                                 null: false
    t.string   "confirmation_name",                      default: "",        null: false
    t.boolean  "signed_agreement",                       default: false,     null: false
    t.boolean  "baptized_at_stmm",                       default: true,      null: false
    t.integer  "baptismal_certificate_id"
  end

  add_index "candidates", ["account_name"], name: "index_candidates_on_account_name", unique: true, using: :btree
  add_index "candidates", ["address_id"], name: "index_candidates_on_address_id", using: :btree
  add_index "candidates", ["baptismal_certificate_id"], name: "index_candidates_on_baptismal_certificate_id", using: :btree
  add_index "candidates", ["reset_password_token"], name: "index_candidates_on_reset_password_token", unique: true, using: :btree

  create_table "confirmation_events", force: :cascade do |t|
    t.string   "name"
    t.date     "the_way_due_date"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "instructions",     default: "", null: false
    t.date     "chs_due_date"
  end

  add_index "confirmation_events", ["name"], name: "index_confirmation_events_on_name", using: :btree

  create_table "to_dos", force: :cascade do |t|
    t.integer  "confirmation_event_id"
    t.integer  "candidate_event_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "to_dos", ["candidate_event_id"], name: "index_to_dos_on_candidate_event_id", using: :btree
  add_index "to_dos", ["confirmation_event_id"], name: "index_to_dos_on_confirmation_event_id", using: :btree

  add_foreign_key "candidates", "addresses"
  add_foreign_key "candidates", "baptismal_certificates"
end
