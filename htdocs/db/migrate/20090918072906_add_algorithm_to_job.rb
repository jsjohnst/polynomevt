class AddAlgorithmToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :algorithm, :string
  end

  def self.down
    remove_column :jobs, :algorithm
  end
end
