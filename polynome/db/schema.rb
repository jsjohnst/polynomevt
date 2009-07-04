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

ActiveRecord::Schema.define(:version => 20090704073236) do

  create_table "jobs", :force => true do |t|
    t.integer  "nodes"
    t.boolean  "simulate"
    t.boolean  "wiring_diagram"
    t.string   "wiring_diagram_format"
    t.boolean  "state_space"
    t.string   "state_space_format"
    t.boolean  "show_probabilities"
    t.boolean  "show_discretized"
    t.boolean  "show_functions"
    t.string   "input_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "update_schedule"
  end

end
