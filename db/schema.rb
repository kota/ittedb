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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120212112519) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "problem_to_tags", :force => true do |t|
    t.integer "problem_id"
    t.integer "tag_id"
  end

  create_table "problems", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "hand"
    t.text     "answer"
    t.integer  "pos_11"
    t.integer  "pos_12"
    t.integer  "pos_13"
    t.integer  "pos_14"
    t.integer  "pos_21"
    t.integer  "pos_22"
    t.integer  "pos_23"
    t.integer  "pos_24"
    t.integer  "pos_31"
    t.integer  "pos_32"
    t.integer  "pos_33"
    t.integer  "pos_34"
    t.integer  "pos_41"
    t.integer  "pos_42"
    t.integer  "pos_43"
    t.integer  "pos_44"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "category_id"
  end

end
