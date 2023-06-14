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

ActiveRecord::Schema[7.0].define(version: 2023_06_14_090552) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "admin_settings", force: :cascade do |t|
    t.hstore "settings", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_attendees", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_attendees_on_event_id"
    t.index ["user_id"], name: "index_event_attendees_on_user_id"
  end

  create_table "event_categories", force: :cascade do |t|
    t.string "event_category"
    t.boolean "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_hashtags", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "hashtag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_hashtags_on_event_id"
    t.index ["hashtag_id"], name: "index_event_hashtags_on_hashtag_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.string "location"
    t.float "latitude"
    t.float "longitude"
    t.boolean "is_approved", default: false
    t.date "start_date"
    t.time "start_time"
    t.date "end_date"
    t.time "end_time"
    t.bigint "user_id", null: false
    t.string "description"
    t.bigint "event_categories_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "event_status"
    t.index ["event_categories_id"], name: "index_events_on_event_categories_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "favourite_events", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_favourite_events_on_event_id"
    t.index ["user_id"], name: "index_favourite_events_on_user_id"
  end

  create_table "hashtags", force: :cascade do |t|
    t.string "name"
    t.boolean "status", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "like_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_like_events_on_event_id"
    t.index ["user_id"], name: "index_like_events_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "dob"
    t.string "phone_number"
    t.string "address"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "reported_by_id"
    t.integer "reported_id"
    t.integer "report_type"
    t.text "description"
    t.integer "status", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_by_id"], name: "index_reports_on_reported_by_id"
  end

  create_table "user_followers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "followed_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["followed_by_id"], name: "index_user_followers_on_followed_by_id"
    t.index ["user_id"], name: "index_user_followers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.boolean "is_admin", default: false
    t.integer "otp", default: 0
    t.boolean "otp_verified", default: false
    t.datetime "otp_generated_at"
    t.string "device_token"
    t.string "device_type"
    t.integer "status"
    t.integer "is_verified", default: 2
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "event_attendees", "events"
  add_foreign_key "event_attendees", "users"
  add_foreign_key "event_hashtags", "events", on_delete: :cascade
  add_foreign_key "event_hashtags", "hashtags"
  add_foreign_key "events", "event_categories", column: "event_categories_id", on_delete: :cascade
  add_foreign_key "events", "users"
  add_foreign_key "favourite_events", "events"
  add_foreign_key "favourite_events", "users"
  add_foreign_key "like_events", "events"
  add_foreign_key "like_events", "users"
  add_foreign_key "profiles", "users", on_delete: :cascade
  add_foreign_key "reports", "users", column: "reported_by_id"
  add_foreign_key "user_followers", "users"
  add_foreign_key "user_followers", "users", column: "followed_by_id"
end
