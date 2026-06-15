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

ActiveRecord::Schema[7.1].define(version: 2026_06_12_074813) do
  # These are extensions that must be enabled in order to support this database
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

  create_table "business_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "shop_name", null: false
    t.string "phone_number", null: false
    t.text "address", null: false
    t.string "upi_id", null: false
    t.string "business_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "business_slug"
    t.string "custom_business_type"
    t.string "country_code"
    t.integer "store_views", default: 0
    t.boolean "is_store_open", default: true
    t.index ["business_slug"], name: "index_business_profiles_on_business_slug", unique: true
    t.index ["user_id"], name: "index_business_profiles_on_user_id"
  end

  create_table "menu_items", force: :cascade do |t|
    t.bigint "business_profile_id", null: false
    t.string "name"
    t.string "category"
    t.text "description"
    t.integer "quantity"
    t.decimal "price"
    t.decimal "discount"
    t.decimal "final_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency"
    t.index ["business_profile_id"], name: "index_menu_items_on_business_profile_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "menu_item_id", null: false
    t.integer "quantity"
    t.decimal "unit_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_item_id"], name: "index_order_items_on_menu_item_id"
    t.index ["order_id"], name: "index_order_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "business_profile_id", null: false
    t.string "customer_name"
    t.string "customer_phone"
    t.string "customer_email"
    t.text "notes"
    t.decimal "total_amount"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "payment_method"
    t.string "payment_status"
    t.string "order_number"
    t.index ["business_profile_id"], name: "index_orders_on_business_profile_id"
  end

  create_table "otp_verifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "email", null: false
    t.string "otp_code", null: false
    t.string "otp_type", default: "email"
    t.datetime "expires_at", null: false
    t.datetime "verified_at"
    t.integer "attempt_count", default: 0
    t.boolean "verified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "otp_code"], name: "index_otp_verifications_on_email_and_otp_code"
    t.index ["email"], name: "index_otp_verifications_on_email"
    t.index ["user_id"], name: "index_otp_verifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "status", default: 0, null: false
    t.boolean "email_verified", default: false
    t.datetime "email_verified_at"
    t.string "google_uid"
    t.boolean "onboarding_completed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_reset_token"
    t.datetime "password_reset_token_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "business_profiles", "users", on_delete: :cascade
  add_foreign_key "menu_items", "business_profiles"
  add_foreign_key "order_items", "menu_items"
  add_foreign_key "order_items", "orders"
  add_foreign_key "orders", "business_profiles"
  add_foreign_key "otp_verifications", "users", on_delete: :cascade
end
