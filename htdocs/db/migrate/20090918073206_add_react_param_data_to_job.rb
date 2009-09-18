class AddReactParamDataToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs, :react_param_data, :string
  end

  def self.down
    remove_column :jobs, :react_param_data
  end
end
