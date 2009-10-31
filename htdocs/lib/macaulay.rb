
class Macaulay
  class << self
    attr_accessor :nodes
    attr_accessor :pvalue
    attr_accessor :logger
    attr_accessor :last_exit_code
  end

  # we do the continue_on_error optionally because we want to sometimes
  # check the return value of a command normally (ie isConsistent) but
  # in most cases we want to just exit on m2 failure
  def self.run(m2_file, m2_command, continue_on_error = false)
    @logger.info "cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e \"#{m2_command}; exit 0;\"; cd ../htdocs;" unless @logger.nil?
    exit_tmp = Tempfile.new("macaulay")
    m2_output = `cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e "#{m2_command}; exit 0;"; echo $? > #{exit_tmp.path}; cd ../htdocs;`
    Macaulay.last_exit_code = exit_tmp.gets.to_i
    exit_tmp.close!
    @logger.info m2_output unless @logger.nil?
    if !continue_on_error && Macaulay.last_exit_code != 0
       @logger.info "Macaulay (#{m2_file}) (#{m2_command}) returned a non-zero exit code (#{$?}), aborting." unless @logger.nil?
       raise MacaulayError.new "Macaulay (#{m2_file}) (#{m2_command}) returned a non-zero exit code (#{$?}), aborting."
    end
    Macaulay.last_exit_code == 0
  end
end

class MacaulayError < RuntimeError

end
