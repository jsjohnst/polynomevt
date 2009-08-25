class Job < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user
  validates_presence_of :nodes
  validates_numericality_of :nodes, :only_integer => true, :message => "Number of nodes must be an integer between 1 and 11"
  validates_numericality_of :nodes, :less_than => 12, :message => "Number of nodes is too big!"
  validates_numericality_of :nodes, :greater_than => 0, :message => "Number of nodes is too small!"
  validates_numericality_of :pvalue, :equal_to => 2
  validate :check_update_schedule
  
  def check_update_schedule
    if update_schedule
      errors.add_to_base("Update schedule not valid " + update_schedule) unless
      update_schedule.match( /^\s*((\d+\s*){#{nodes}})?\s*$/ )
    end
  end
end
