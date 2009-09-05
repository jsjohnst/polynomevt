class Job < ActiveRecord::Base
  belongs_to :user
  
  # enum_field information can be found at the following URL:
  # http://giraffesoft.ca/blog/2009/02/17/floss-week-day-2-the-enum-field-rails-plugin.html
  # by having this, we get the handy sequential? check among other things
  enum_field :update_type, [ 'sequential', '' ]
  
  # default_value_for information can be found at the following URL:
  # http://blog.phusion.nl/2008/10/03/47/
  default_value_for :update_type, ''
  
  validates_presence_of :user
  validates_presence_of :nodes
  validates_length_of :input_data, :minimum => 1
  validates_numericality_of :nodes, :only_integer => true, :message => "Number of nodes must be an integer between 1 and 11"
  validates_numericality_of :nodes, :less_than => 12, :message => "Number of nodes is too big!"
  validates_numericality_of :nodes, :greater_than => 0, :message => "Number of nodes is too small!"
  validates_numericality_of :pvalue, :equal_to => 2
  validate :check_update_schedule
  validate :check_stochastic_options
  validate :check_state_space
  validate :check_input_data 

  # remove blank lines from data before working with it
  def input_data=(data)
    tmp = []
    data.each_line do |line| 
      line.strip!
      if !line.empty?
        tmp.push line
      end
    end
    data = tmp.join "\n"
    write_attribute(:input_data, data)
  end

  def check_input_data
    if !input_data 
      errors.add("input_data", "You didn't enter any data") 
      return
    end
    nodes_minus_one = (nodes - 1)
    #puts "Nodes-1 " + nodes_minus_one.to_s
    input_data.each_line do |line| 
      line.strip!
      if nodes_minus_one > 0
        errors.add("input_data", "The data you entered is invalid. This :#{line.chop!}: is not a correct line.") unless 
          (line.match( /^\s*\#+/ ) ||  line.match( /^\s*(\.?\d+\.?\d*\s+){#{nodes_minus_one.to_s}}\.?\d+\.?\d*\s*$/ ))
      else
        errors.add("input_data", "The data you entered is invalid. This :#{line.chop!}: is not a correct line.") unless 
          (line.match( /^\s*\#+/) || line.match( /^\s*\.?\d+\.?\d*\s*$/ ))
      end
    end
  end

  def check_state_space
    # TODO: We should try to just force this on instead of erroring
    if self.show_state_space
      errors.add("show_functions", "must also be selected if you want to show state space.") unless show_functions
    end
  end
  
  def check_update_schedule
    if update_schedule
      errors.add("update_schedule", "not valid! " + update_schedule) unless
      update_schedule.match( /^\s*((\d+\s*){#{nodes}})?\s*$/ )
    end
  end
  
  def check_stochastic_options
    if !make_deterministic_model
      if show_state_space
        errors.add_to_base("A stochastic model with more than 10 nodes cannot be simulated.") unless
        nodes <= 10 # if you update this, be sure and update the error message above too
      end
      
      errors.add_to_base("Sequential updates can only be chosen for deterministic models.") unless !sequential?
      
      # TODO: Need to somehow add a log / warning about random schedule if we don't have an update_schedule
    end
  end

end
