require 'algorithm'
require 'data_integrity'

class ParameterEstimation < Algorithm 
  def self.run(discretized_file, functionfile)
    n_react_threshold = 5
		if(Algorithm.job.make_deterministic_model)
	    if(Algorithm.job.nodes < n_react_threshold)
      	self.run_react(discretized_file)
			else
      	DataIntegrity.makeConsistent(discretized_file)	
				self.run_minsets(discretized_file, functionfile)
				self.run_dvdcore
			end
		else # stochastic
      DataIntegrity.makeConsistent(discretized_file)
			self.run_gfan(discretized_file, functionfile)
			self.run_dvdcore	
		end
	end

  def self.run_gfan
		self.run_macaulay("sgfan.m2", "sgfan(///#{discretized_file}///, ///#{functionfile}///, #{Algorithm.job.pvalue}, #{Algorithm.job.nodes})")
  end

	def self.run_minsets(discretized_file, functionfile)	
		self.run_macaulay("minsets-web.m2", "minsetsPDS(///#{discretized_file}///, ///#{functionfile}///, #{Algorithm.job.pvalue}, #{Algorithm.job.nodes})")
	end
end
