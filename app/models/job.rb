class Job < ActiveRecord::Base
  validates_presence_of :nodes
  validates_numericality_of :nodes, :only_integer => true, :greater_than => 1, :message => "Number of nodes must be at least 2"


end
