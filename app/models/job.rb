class Job < ActiveRecord::Base
  validates_presence_of :nodes, :on => :create
  validates_numericality_of :nodes, :only_integer => true, :message => "Number of nodes must be an integer between 1 and 11", :on => :create
  validates_numericality_of :nodes, :less_than => 12, :message => "Number of nodes is too big!", :on => :create
  validates_numericality_of :nodes, :greater_than => 0, :message => "Number of nodes is too small!", :on => :create

  # check update schedule to be blank or the right reges
  validates_format_of :update_schedule, :with => /^\s*(\d+\s*){#{:nodes}}\d+\s*$/, :allow_blank => :true, :on => :create
  
  def file_prefix
    @file_prefix
  end
  def file_prefix=(file_prefix)
    @file_prefix = file_prefix
  end

end
