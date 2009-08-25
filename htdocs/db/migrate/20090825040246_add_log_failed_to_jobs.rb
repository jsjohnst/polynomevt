class AddLogFailedToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :log, :text
    add_column :jobs, :failed, :boolean
  end

  def self.down
    remove_column :jobs, :failed
    remove_column :jobs, :log
  end
end
