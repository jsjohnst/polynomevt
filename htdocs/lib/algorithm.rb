
class Algorithm
  class << self
    attr_accessor :job
    attr_accessor :logger
    attr_accessor :last_m2_exit_code
  end

  # we do the continue_on_error optionally because we want to sometimes
  # check the return value of a command normally (ie isConsistent) but
  # in most cases we want to just exit on m2 failure
  def self.run_macaulay(m2_file, m2_command, continue_on_error = false)
    @logger.info "cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e \"#{m2_command}; exit 0;\"; cd ../htdocs;" unless @logger.nil?
    exit_tmp = Tempfile.new("macaulay")
    m2_output = `cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e "#{m2_command}; exit 0;"; echo $? > #{exit_tmp.path}; cd ../htdocs;`
    Algorithm.last_m2_exit_code = exit_tmp.gets.to_i
    exit_tmp.close!
    @logger.info m2_output unless @logger.nil?
    if !continue_on_error && Algorithm.last_m2_exit_code != 0
       @logger.info "Macaulay (#{m2_file}) (#{m2_command}) returned a non-zero exit code (#{$?}), aborting." unless @logger.nil?
       raise MacaulayError.new "Macaulay (#{m2_file}) (#{m2_command}) returned a non-zero exit code (#{$?}), aborting."
    end
    Algorithm.last_m2_exit_code == 0
  end

	def self.run_dvdcore
		dvd = DVDCore.new(Algorithm.job.file_prefix, Algorithm.job.nodes, Algorithm.job.pvalue)
    dvd.create_wiring_diagram = Algorithm.job.show_wiring_diagram
    dvd.create_state_space = Algorithm.job.show_state_space
    dvd.show_probabilities = Algorithm.job.show_probabilities_state_space
    dvd.run
	end

	def self.run_react(discretized_file)
    react = React.new(Algorithm.job.file_prefix, Algorithm.job.nodes)
    react.discretized_data_file = discretized_file
    react.run
		self.run_dvdcore
  end
end

class MacaulayError < RuntimeError

end
