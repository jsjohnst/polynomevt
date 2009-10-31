require 'macaulay'

class Discretize < Macaulay
  def self.run(datafile, discretized_file)
		super("Discretize.m2", "discretize(///#{datafile}///, 0, ///#{discretized_file}///)")
  end
end
