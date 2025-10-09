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

ActiveRecord::Schema[8.0].define(version: 2025_10_09_011009) do
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

  create_table "commissions", force: :cascade do |t|
    t.bigint "sale_id", null: false
    t.bigint "agent_id", null: false
    t.decimal "percentage", precision: 5, scale: 2
    t.decimal "value", precision: 12, scale: 2
    t.boolean "paid", default: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sale_id"], name: "index_commissions_on_sale_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.text "body"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.decimal "price", precision: 12, scale: 2
    t.integer "property_type", default: 0, null: false
    t.decimal "area", precision: 10, scale: 2
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "parking_spaces"
    t.boolean "furnished", default: false
    t.decimal "condominium_fee", precision: 10, scale: 2
    t.decimal "iptu", precision: 10, scale: 2
    t.integer "year_built"
    t.string "address"
    t.string "neighborhood"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.integer "status", default: 0, null: false
    t.bigint "agent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_properties_on_agent_id"
  end

  create_table "property_photos", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_property_photos_on_property_id"
  end

  create_table "sales", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.bigint "agent_id", null: false
    t.bigint "buyer_id"
    t.decimal "sale_price", precision: 12, scale: 2
    t.date "sale_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_sales_on_property", unique: true
    t.index ["property_id"], name: "index_sales_on_property_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "phone"
    t.integer "role", default: 2, null: false
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
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
    t.index ["property_id"], name: "index_visits_on_property_id"
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
  add_foreign_key "visits", "properties"
  add_foreign_key "visits", "users", column: "agent_id"
  add_foreign_key "visits", "users", column: "buyer_id"
end
