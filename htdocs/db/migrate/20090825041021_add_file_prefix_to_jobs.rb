class AddFilePrefixToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :file_prefix, :string
  end

  def self.down
    remove_column :jobs, :file_prefix
  end
end
