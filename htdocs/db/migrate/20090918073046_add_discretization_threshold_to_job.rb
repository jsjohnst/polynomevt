class AddDiscretizationThresholdToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :discretization_threshold, :integer
  end

  def self.down
    remove_column :jobs, :discretization_threshold
  end
end
