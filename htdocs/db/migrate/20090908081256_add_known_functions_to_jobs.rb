class AddKnownFunctionsToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :known_functions, :text
  end

  def self.down
    remove_column :jobs, :known_functions
  end
end
