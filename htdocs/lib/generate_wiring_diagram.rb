require 'algorithm'
require 'data_integrity'

class GenerateWiringDiagram < Algorithm 
  def self.run(discretized_file, wiring_diagram_dotfile)
    n_react_threshold = 5
    if(Algorithm.job.nodes < n_react_threshold)
			if !DataIntegrity.consistent?(discretized_file)
      	self.run_react(discretized_file)
			else
				self.run_gfan(discretized_file, wiring_diagram_dotfile)
			end
		else
      DataIntegrity.makeConsistent(discretized_file)	
			self.run_minsets(discretized_file, wiring_diagram_dotfile)
		end
	end

  def self.run_gfan(discretized_file, wiring_diagram_dotfile)
		self.run_macaulay("wd.m2", "wd(///#{discretized_file}///, ///#{wiring_diagram_dotfile}///, #{Algorithm.job.pvalue}, #{Algorithm.job.nodes})")
	end

	def self.run_minsets(discretized_file, wiring_diagram_dotfile)	
		self.run_macaulay("minsets-web.m2", "minsetsWD(///#{discretized_file}///, ///#{wiring_diagram_dotfile}///, #{Algorithm.job.pvalue}, #{Algorithm.job.nodes})")
	end
end
