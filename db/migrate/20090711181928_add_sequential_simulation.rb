class AddSequentialSimulation < ActiveRecord::Migration
  def self.up
    add_column :jobs, :sequential, :boolean
  end

  def self.down
    remove_column :jobs, :sequential
  end
end
