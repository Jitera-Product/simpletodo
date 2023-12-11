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

ActiveRecord::Schema[7.0].define(version: 2023_12_11_152309) do
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

  create_table "attachments", comment: "Stores files attached to todos", force: :cascade do |t|
    t.string "file_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "todo_id"
    t.index ["todo_id"], name: "index_attachments_on_todo_id"
  end

  create_table "authentication_tokens", comment: "Stores authentication tokens for users", force: :cascade do |t|
    t.datetime "expires_at", precision: nil
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "categories", comment: "Stores categories that can be assigned to todos", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dashboards", comment: "Represents the users dashboard after successful sign in", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_dashboards_on_user_id"
  end

  create_table "email_confirmation_requests", comment: "Stores requests for resending confirmation emails", force: :cascade do |t|
    t.datetime "requested_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_email_confirmation_requests_on_user_id"
  end

  create_table "email_confirmations", comment: "Stores email confirmation tokens and their expiration", force: :cascade do |t|
    t.datetime "expires_at", precision: nil
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_email_confirmations_on_user_id"
  end

  create_table "password_reset_tokens", comment: "Stores password reset tokens for users", force: :cascade do |t|
    t.boolean "used"
    t.datetime "expires_at", precision: nil
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "tags", comment: "Stores tags that can be assigned to todos", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "todo_categories", comment: "Associative table to link todos and categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.bigint "todo_id"
    t.index ["category_id"], name: "index_todo_categories_on_category_id"
    t.index ["todo_id"], name: "index_todo_categories_on_todo_id"
  end

  create_table "todo_tags", comment: "Associative table to link todos and tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "todo_id"
    t.bigint "tag_id"
    t.index ["tag_id"], name: "index_todo_tags_on_tag_id"
    t.index ["todo_id"], name: "index_todo_tags_on_todo_id"
  end

  create_table "todos", comment: "Stores to-do items for users", force: :cascade do |t|
    t.integer "recurrence", default: 0
    t.string "title"
    t.integer "priority", default: 0
    t.datetime "due_date", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "status", default: 0
    t.string "description"
    t.index ["user_id"], name: "index_todos_on_user_id"
  end

  create_table "trashes", comment: "Stores deleted to-do items for potential recovery", force: :cascade do |t|
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", comment: "Stores user account information", force: :cascade do |t|
    t.string "confirmation_token"
    t.string "name"
    t.boolean "email_confirmed"
    t.string "email"
    t.datetime "confirmation_token_created_at", precision: nil
    t.string "password_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attachments", "todos"
  add_foreign_key "authentication_tokens", "users"
  add_foreign_key "dashboards", "users"
  add_foreign_key "email_confirmation_requests", "users"
  add_foreign_key "email_confirmations", "users"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "todo_categories", "categories"
  add_foreign_key "todo_categories", "todos"
  add_foreign_key "todo_tags", "tags"
  add_foreign_key "todo_tags", "todos"
  add_foreign_key "todos", "users"
end
