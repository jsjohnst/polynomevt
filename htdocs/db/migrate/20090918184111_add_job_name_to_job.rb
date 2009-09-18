class AddJobNameToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :job_name, :string
  end

  def self.down
    remove_column :jobs, :job_name
  end
end
