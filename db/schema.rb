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

ActiveRecord::Schema.define(version: 2018_11_03_141301) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.uuid "trip_id"
    t.uuid "guest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_bookings_on_created_by_id"
    t.index ["guest_id"], name: "index_bookings_on_guest_id"
    t.index ["trip_id"], name: "index_bookings_on_trip_id"
    t.index ["updated_by_id"], name: "index_bookings_on_updated_by_id"
  end

  create_table "guests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone_number"
    t.text "address"
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.index ["email"], name: "index_guests_on_email", unique: true
    t.index ["reset_password_token"], name: "index_guests_on_reset_password_token", unique: true
  end

  create_table "guides", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "phone_number"
    t.text "address"
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.index ["email"], name: "index_guides_on_email", unique: true
    t.index ["reset_password_token"], name: "index_guides_on_reset_password_token", unique: true
  end

  create_table "guides_trips", id: false, force: :cascade do |t|
    t.uuid "guide_id", null: false
    t.uuid "trip_id", null: false
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guide_id", "trip_id"], name: "index_guides_trips_on_guide_id_and_trip_id"
    t.index ["trip_id", "guide_id"], name: "index_guides_trips_on_trip_id_and_guide_id"
  end

  create_table "organisation_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "owner", default: false
    t.uuid "organisation_id"
    t.uuid "guide_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guide_id"], name: "index_organisation_memberships_on_guide_id"
    t.index ["organisation_id"], name: "index_organisation_memberships_on_organisation_id"
  end

  create_table "organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.text "address"
    t.string "stripe_account_id"
    t.string "subdomain"
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.float "flat_fee_amount"
    t.float "percentage_amount"
    t.integer "charge_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "minimum_number_of_guests"
    t.integer "maximum_number_of_guests"
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "organisation_id"
    t.index ["organisation_id"], name: "index_trips_on_organisation_id"
  end

  add_foreign_key "bookings", "guests"
  add_foreign_key "bookings", "trips"
  add_foreign_key "organisation_memberships", "guides"
  add_foreign_key "organisation_memberships", "organisations"
  add_foreign_key "organisations", "guides", column: "created_by_id"
  add_foreign_key "organisations", "guides", column: "updated_by_id"
  add_foreign_key "trips", "organisations"
end
