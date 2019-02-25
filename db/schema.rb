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

ActiveRecord::Schema.define(version: 2019_02_25_131644) do

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
    t.string "email"
    t.string "name"
    t.string "country"
    t.string "phone_number"
    t.datetime "date_of_birth"
    t.string "address"
    t.string "city"
    t.string "county"
    t.string "post_code"
    t.string "next_of_kin_name"
    t.string "next_of_kin_phone_number"
    t.integer "dietary_requirements"
    t.integer "allergies"
    t.text "medical_conditions"
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
    t.string "name_booking"
    t.string "name_override"
    t.string "email_booking"
    t.string "email_override"
    t.string "country"
    t.string "country_booking"
    t.string "country_override"
    t.string "phone_number_booking"
    t.string "phone_number_override"
    t.datetime "date_of_birth"
    t.datetime "date_of_birth_booking"
    t.datetime "date_of_birth_override"
    t.string "address_booking"
    t.string "address_override"
    t.string "city"
    t.string "city_booking"
    t.string "city_override"
    t.string "county"
    t.string "county_booking"
    t.string "county_override"
    t.string "post_code"
    t.string "post_code_booking"
    t.string "post_code_override"
    t.string "next_of_kin_name"
    t.string "next_of_kin_name_booking"
    t.string "next_of_kin_name_override"
    t.string "next_of_kin_phone_number"
    t.string "next_of_kin_phone_number_booking"
    t.string "next_of_kin_phone_number_override"
    t.integer "dietary_requirements"
    t.integer "dietary_requirements_booking"
    t.integer "dietary_requirements_override"
    t.integer "allergies"
    t.integer "allergies_booking"
    t.integer "allergies_override"
    t.text "medical_conditions"
    t.text "medical_conditions_booking"
    t.text "medical_conditions_override"
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
    t.integer "currency"
  end

  create_table "plans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.float "flat_fee_amount"
    t.float "percentage_amount"
    t.integer "charge_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "created_by_id"
    t.uuid "updated_by_id"
    t.uuid "organisation_id"
    t.uuid "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_subscriptions_on_created_by_id"
    t.index ["organisation_id"], name: "index_subscriptions_on_organisation_id"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["updated_by_id"], name: "index_subscriptions_on_updated_by_id"
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
    t.integer "currency"
    t.text "description"
    t.float "full_cost"
    t.float "deposit_cost"
    t.index ["organisation_id"], name: "index_trips_on_organisation_id"
  end

  add_foreign_key "bookings", "guests"
  add_foreign_key "bookings", "trips"
  add_foreign_key "organisation_memberships", "guides"
  add_foreign_key "organisation_memberships", "organisations"
  add_foreign_key "organisations", "guides", column: "created_by_id"
  add_foreign_key "organisations", "guides", column: "updated_by_id"
  add_foreign_key "subscriptions", "organisations"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "trips", "organisations"
end
