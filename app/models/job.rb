class Job < ActiveRecord::Base
  validates_presence_of :nodes
  validates_numericality_of :nodes, :only_integer => true, :message => "Number of nodes must be an integer between 1 and 11"
  validates_numericality_of :nodes, :less_than => 12, :message => "Number of nodes is too big!"
  validates_numericality_of :nodes, :greater_than => 0, :message => "Number of nodes is too small!"

  def file_prefix
    @file_prefix
  end
  def file_prefix=(file_prefix)
    @file_prefix = file_prefix
  end

end
