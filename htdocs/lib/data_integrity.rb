require 'macaulay'

class DataIntegrity < Macaulay
  def self.consistent?(discretized_file)
		self.run("isConsistent.m2", "isConsistent(///#{discretized_file}///, #{Macaulay.pvalue}, #{Macaulay.nodes})", true)
		Macaulay.last_exit_code == 42
  end

  def self.makeConsistent(datafile, consistent_datafile)
		self.run("incons.m2", "makeConsistent(///#{datafile}///, ///#{consistent_datafile}///)")
  end
end
