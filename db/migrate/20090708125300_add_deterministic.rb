class AddDeterministic < ActiveRecord::Migration
  def self.up
    add_column :jobs, :is_deterministic, :boolean
  end

  def self.down
    remove_column :jobs, :is_deterministic
  end
end
