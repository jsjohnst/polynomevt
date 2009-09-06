class User < ActiveRecord::Base
  has_many :job
  validates_associated :job
  validates_length_of :login, :within => 3..40, :message => "Invalid login"
  validates_length_of :password, :within => 6..40
  validates_presence_of :login , :password
  validates_uniqueness_of :login
  validates_uniqueness_of :email, :allow_nil => true, :allow_blank => true
  validates_confirmation_of :password
  validates_format_of :email, :with => /^(([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}))*$/i, :message => "Invalid email"
end
