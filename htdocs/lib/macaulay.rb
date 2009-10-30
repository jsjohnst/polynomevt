
class Macaulay
  class << self
    attr_accessor :logger
  end

  # we do the continue_on_error optionally because we want to sometimes
  # check the return value of a command normally (ie isConsistent) but
  # in most cases we want to just exit on m2 failure
  def self.run(m2_file, m2_command, continue_on_error = false)
    @logger.info "cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e \"#{m2_command}; exit 0;\"; cd ../htdocs;"
    @logger.info `cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e "#{m2_command}; exit 0;"; cd ../htdocs;`
    if continue_on_error && $? != 0
       @logger.info "Macaulay (#{m2_file}) (#{m2_command}) returned a non-zero exit code (#{$?}), aborting."
       raise MacaulayError.new "Macaulay (#{m2_file}) (#{m2_command}) returned a non-zero exit code (#{$?}), aborting."
    end
    $? == 0
  end
end

class MacaulayError < RuntimeError

end
