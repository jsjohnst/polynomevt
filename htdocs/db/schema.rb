# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090918184111) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "nodes"
    t.integer  "pvalue"
    t.boolean  "show_wiring_diagram"
    t.string   "wiring_diagram_format"
    t.boolean  "show_state_space"
    t.string   "state_space_format"
    t.boolean  "show_discretized"
    t.boolean  "show_functions"
    t.text     "input_data"
    t.boolean  "show_probabilities_wiring_diagram"
    t.boolean  "show_probabilities_state_space"
    t.boolean  "make_deterministic_model"
    t.string   "update_type"
    t.string   "update_schedule"
    t.boolean  "completed"
    t.boolean  "deleted"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "log"
    t.boolean  "failed"
    t.string   "file_prefix"
    t.text     "known_functions"
    t.string   "algorithm"
    t.integer  "discretization_threshold"
    t.integer  "probability_threshold"
    t.string   "react_param_data"
    t.string   "job_name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "organization"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
