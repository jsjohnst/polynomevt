require 'algorithm'

class DataIntegrity < Algorithm
  def self.consistent?(discretized_file)
		self.run_macaulay("isConsistent.m2", "isConsistent(///#{discretized_file}///, #{Algorithm.job.pvalue}, #{Algorithm.job.nodes})", true)
		Algorithm.last_m2_exit_code == 42
  end

  def self.makeConsistent(datafile, consistent_datafile)
		self.run_macaulay("incons.m2", "makeConsistent(///#{datafile}///, ///#{consistent_datafile}///)")
  end
end
