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

ActiveRecord::Schema.define(version: 2018_09_14_102652) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "authentication_tokens", force: :cascade do |t|
    t.bigint "user_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_authentication_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "content_blocks", force: :cascade do |t|
    t.bigint "content_id"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "block_type"
    t.integer "order"
    t.jsonb "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_content_blocks_on_content_id"
  end

  create_table "contents", force: :cascade do |t|
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }
    t.string "content_type"
    t.jsonb "title"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id"
    t.bigint "user_id"
    t.index ["organization_id"], name: "index_contents_on_organization_id"
    t.index ["user_id"], name: "index_contents_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.index ["name"], name: "index_organizations_on_name"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
  end

  create_table "organizations_users", id: false, force: :cascade do |t|
    t.bigint "organization_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.index ["organization_id"], name: "index_organizations_users_on_organization_id"
    t.index ["user_id"], name: "index_organizations_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "given_name"
    t.string "family_name"
    t.string "role", default: "USER", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verification_token"
    t.boolean "email_verified", default: false
    t.string "gender"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "authentication_tokens", "users"
  add_foreign_key "content_blocks", "contents"
  add_foreign_key "contents", "organizations"
  add_foreign_key "contents", "users"
  add_foreign_key "organizations", "organizations", column: "parent_id"
end
