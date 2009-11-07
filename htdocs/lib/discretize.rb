require 'algorithm'

class Discretize < Algorithm
  # for now either regular discretize is used or discretization according to
  # intervals if p value is not 2
  def self.run(datafile, pvalue, discretized_file)
    if pvalue == 2 
      self.run_macaulay("Discretize.m2", "discretize(///#{datafile}///, 0, ///#{discretized_file}///)")
    else
      self.run_macaulay("Discretize-interval.m2", "discretize(///#{datafile}///, 0, #{pvalue}, ///#{discretized_file}///)")
    end
  end
end
