class Job < ActiveRecord::Base
  belongs_to :user
  
  # enum_field information can be found at the following URL:
  # http://giraffesoft.ca/blog/2009/02/17/floss-week-day-2-the-enum-field-rails-plugin.html
  # by having this, we get the handy sequential? check among other things
  enum_field :update_type, [ 'sequential', '' ]
  
  # default_value_for information can be found at the following URL:
  # http://blog.phusion.nl/2008/10/03/47/
  default_value_for :update_type, ''
  default_value_for :pvalue, 2
  default_value_for :show_wiring_diagram, true
  default_value_for :show_state_space, true
  default_value_for :wiring_diagram_format, "gif"
  default_value_for :state_space_format, "gif"
  
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

  # remove blank lines from end of data before working with it
  # We don't remove blank lines in the middle, because the correct and only
  # way to enter multiplte time courses is with hash symbols
  def input_data=(data)
    data.strip!
    write_attribute(:input_data, data)
  end

  def check_input_data
    if !input_data 
      errors.add("input_data", "You didn't enter any data") 
      return
    end
    if !nodes
      errors.add("nodes", "You didn't specify any nodes")
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
    if self.show_state_space
      write_attribute(:show_functions, true)
    end
  end
  
  def check_update_schedule
    if update_schedule
      errors.add("update_schedule", "not valid! " + update_schedule) unless
      update_schedule.match( /^\s*((\d+\s*){#{nodes}})?\s*$/ )
      errors.add("update_schedule", "non-unique functions in schedule") unless
      update_schedule.strip.length < 1 || update_schedule.strip.split( /\s*/ ).uniq.length == nodes
    end
  end
  
  def check_stochastic_options
    if !make_deterministic_model
      if show_state_space
        if !nodes.nil?
		errors.add_to_base("A stochastic model with more than 11 nodes cannot be simulated.") unless
        		nodes <= 11 # if you update this, be sure and update the error message above too
	end
      end
      
      errors.add_to_base("Sequential updates can only be chosen for deterministic models.") unless !sequential?
      
      # TODO: Need to somehow add a log / warning about random schedule if we don't have an update_schedule
    end
  end

end
