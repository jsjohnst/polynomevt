class AddProbabilityThresholdToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :probability_threshold, :integer
  end

  def self.down
    remove_column :jobs, :probability_threshold
  end
end
