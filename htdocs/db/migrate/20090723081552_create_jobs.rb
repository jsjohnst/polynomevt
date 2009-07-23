class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :nodes
      t.integer :pvalue
      t.boolean :show_wiring_diagram
      t.string :wiring_diagram_format
      t.boolean :show_state_space
      t.string :state_space_format
      t.boolean :show_discretized
      t.boolean :show_functions
      t.text :input_data
      t.boolean :show_probabilities_wiring_diagram
      t.boolean :show_probabilities_state_space
      t.boolean :make_deterministic_model
      t.string :update_type
      t.string :update_schedule
      t.boolean :completed
      t.boolean :deleted
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
