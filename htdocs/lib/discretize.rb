require 'algorithm'

class Discretize < Algorithm
  def self.run(datafile, discretized_file)
		self.run_macaulay("Discretize.m2", "discretize(///#{datafile}///, 0, ///#{discretized_file}///)")
  end
end
