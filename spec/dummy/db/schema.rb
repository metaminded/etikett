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

ActiveRecord::Schema.define(version: 20140526064138) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: true do |t|
    t.integer  "product_no"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "etikett_tag_categories", force: true do |t|
    t.string   "name"
    t.integer  "parent_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "etikett_tag_categories", ["parent_category_id"], name: "index_etikett_tag_categories_on_parent_category_id", using: :btree

  create_table "etikett_tag_categories_tags", force: true do |t|
    t.integer  "tag_id"
    t.integer  "tag_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "etikett_tag_mappings", force: true do |t|
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tag_id"
    t.string   "type"
    t.string   "typ"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "etikett_tag_mappings", ["tag_id"], name: "index_etikett_tag_mappings_on_tag_id", using: :btree

  create_table "etikett_tag_synonyms", force: true do |t|
    t.string   "name"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "etikett_tag_synonyms", ["tag_id"], name: "index_etikett_tag_synonyms_on_tag_id", using: :btree

  create_table "etikett_tags", force: true do |t|
    t.string   "name"
    t.boolean  "generated",  default: false
    t.string   "nice"
    t.integer  "prime_id"
    t.string   "prime_type"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lectures", force: true do |t|
    t.string "title"
  end

  create_table "posts", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
