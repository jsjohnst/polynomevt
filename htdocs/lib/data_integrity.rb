require 'macaulay'

class DataIntegrity < Macaulay
  def self.consistent?(discretized_file)
		self.run("isConsistent.m2", "isConsistent(///#{discretized_file}///, #{@pvalue}, #{@nodes})", true)
  end

  def self.makeConsistent(datafile, consistent_datafile)
		self.run("incons.m2", "makeConsistent(///#{datafile}///, #{@nodes}, ///#{consistent_datafile}///)")
  end
end
