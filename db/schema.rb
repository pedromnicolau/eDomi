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

ActiveRecord::Schema[8.0].define(version: 2025_11_05_192613) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "addresses", force: :cascade do |t|
    t.string "address_line1", null: false
    t.string "address_line2"
    t.string "neighborhood"
    t.string "city", null: false
    t.string "state", limit: 2, null: false
    t.string "zip_code"
    t.string "country", default: "BR", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.integer "address_type", default: 0, null: false
    t.boolean "primary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    t.check_constraint "char_length(state::text) = 2", name: "addresses_state_len_2"
  end

  create_table "commissions", force: :cascade do |t|
    t.bigint "sale_id", null: false
    t.bigint "agent_id", null: false
    t.decimal "percentage", precision: 5, scale: 2, null: false
    t.decimal "value", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "paid", default: false, null: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sale_id", "agent_id"], name: "index_commissions_on_sale_id_and_agent_id", unique: true
    t.index ["sale_id"], name: "index_commissions_on_sale_id"
    t.check_constraint "percentage >= 0::numeric AND percentage <= 100::numeric", name: "commissions_percentage_range"
    t.check_constraint "value >= 0::numeric", name: "commissions_value_non_negative"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "cnpj"
    t.string "email"
    t.string "phone"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_companies_on_cnpj", unique: true
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.boolean "read", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "read"], name: "index_notifications_on_user_id_and_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.date "birthdate"
    t.integer "status", default: 0, null: false
    t.integer "preferred_contact_method", default: 0, null: false
    t.text "notes"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_people_on_email", unique: true
  end

  create_table "properties", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.decimal "price", precision: 12, scale: 2, null: false
    t.integer "property_type", null: false
    t.decimal "area", precision: 10, scale: 2
    t.integer "bedrooms", default: 0, null: false
    t.integer "bathrooms", default: 0, null: false
    t.integer "parking_spaces", default: 0, null: false
    t.boolean "furnished", default: false, null: false
    t.decimal "condominium_fee", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "iptu", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "year_built"
    t.integer "status", default: 0, null: false
    t.bigint "agent_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_properties_on_agent_id"
    t.index ["bedrooms", "bathrooms"], name: "index_properties_on_bedrooms_and_bathrooms"
    t.index ["price"], name: "index_properties_on_price"
    t.index ["property_type"], name: "index_properties_on_property_type"
    t.index ["status"], name: "index_properties_on_status"
    t.check_constraint "bathrooms >= 0", name: "properties_bathrooms_non_negative"
    t.check_constraint "bedrooms >= 0", name: "properties_bedrooms_non_negative"
    t.check_constraint "condominium_fee >= 0::numeric", name: "properties_condo_fee_non_negative"
    t.check_constraint "iptu >= 0::numeric", name: "properties_iptu_non_negative"
    t.check_constraint "parking_spaces >= 0", name: "properties_parking_non_negative"
    t.check_constraint "price >= 0::numeric", name: "properties_price_non_negative"
  end

  create_table "property_photos", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.integer "position", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "position"], name: "index_property_photos_on_property_id_and_position", unique: true
    t.index ["property_id"], name: "index_property_photos_on_property_id"
  end

  create_table "sales", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "agent_id", null: false
    t.bigint "buyer_id", null: false
    t.decimal "sale_price", precision: 12, scale: 2, null: false
    t.date "sale_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "sale_date"], name: "index_sales_on_property_id_and_sale_date"
    t.index ["property_id"], name: "index_sales_on_property_id"
    t.index ["sale_date"], name: "index_sales_on_sale_date"
    t.check_constraint "sale_price >= 0::numeric", name: "sales_price_non_negative"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "role"
    t.bigint "person_id"
    t.string "provider"
    t.string "uid"
    t.string "email_verification_token"
    t.datetime "email_verified_at"
    t.datetime "verification_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_verification_token"], name: "index_users_on_email_verification_token", unique: true
    t.index ["person_id"], name: "index_users_on_person_id"
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "agent_id", null: false
    t.datetime "scheduled_at", null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "scheduled_at"], name: "index_visits_on_agent_id_and_scheduled_at"
    t.index ["property_id", "scheduled_at"], name: "index_visits_on_property_id_and_scheduled_at"
    t.index ["property_id"], name: "index_visits_on_property_id"
    t.index ["scheduled_at"], name: "index_visits_on_scheduled_at"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "commissions", "sales"
  add_foreign_key "commissions", "users", column: "agent_id"
  add_foreign_key "notifications", "users"
  add_foreign_key "properties", "users", column: "agent_id"
  add_foreign_key "property_photos", "properties"
  add_foreign_key "sales", "properties"
  add_foreign_key "sales", "users", column: "agent_id"
  add_foreign_key "sales", "users", column: "buyer_id"
  add_foreign_key "users", "people"
  add_foreign_key "visits", "properties"
  add_foreign_key "visits", "users", column: "agent_id"
  add_foreign_key "visits", "users", column: "buyer_id"
end
