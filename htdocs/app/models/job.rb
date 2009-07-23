class Job < ActiveRecord::Base
  belongs_to :user
  validates_associated :user
  validates_presence_of :user, :message => "Must associate with a user, even if that's just the guest login"
  validates_numericality_of :nodes, :greater_than_or_equal_to => 1, 
                             :only_integer => true, :less_than_or_equal_to => 10
  validates_numericality_of :pvalue, :equal_to => 2
end
