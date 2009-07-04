class AddSchedule < ActiveRecord::Migration
  def self.up
    add_column :jobs, :update_schedule, :string
  end

  def self.down
    remove_column :jobs, :update_schedule
  end
end
