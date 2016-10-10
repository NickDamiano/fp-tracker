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

ActiveRecord::Schema.define(version: 20160826183617) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "employees", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_num1"
    t.string   "phone_num2"
    t.string   "location"
    t.string   "job_title"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "in_country"
    t.boolean  "permanent"
    t.boolean  "queries_pending"
    t.boolean  "admin"
  end

  create_table "message_queries", force: :cascade do |t|
    t.string   "body"
    t.string   "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: :cascade do |t|
    t.string   "messageSid"
    t.string   "from"
    t.string   "to"
    t.string   "body"
    t.datetime "time_received"
    t.integer  "employee_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "status"
    t.boolean  "pending_response"
    t.string   "location"
  end

  add_index "messages", ["employee_id"], name: "index_messages_on_employee_id", using: :btree

  create_table "transit_employees", force: :cascade do |t|
    t.string   "sender"
    t.string   "destination"
    t.string   "string"
    t.integer  "employee_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

end
