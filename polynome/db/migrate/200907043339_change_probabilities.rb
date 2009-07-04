class ChangeProbabilities < ActiveRecord::Migration
  def self.up
    remove_column :jobs, :show_probabilities
    add_column :jobs, :show_probabilities_wiring_diagram, :boolean
    add_column :jobs, :show_probabilities_state_space, :boolean
  end

  def self.down
    add_column :jobs, :show_probabilities
    remove_column :jobs, :show_probabilities_wiring_diagram
    remove_column :jobs, :show_probabilities_state_space
  end
end
