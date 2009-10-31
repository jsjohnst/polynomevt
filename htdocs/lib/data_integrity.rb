require 'algorithm'

# Only run these DataIntegrity methods on discretized data

class DataIntegrity < Algorithm
  def self.consistent?(file)
		self.run_macaulay("isConsistent.m2", "isConsistent(///#{file}///, #{Algorithm.job.pvalue}, #{Algorithm.job.nodes})", true)
		Algorithm.last_m2_exit_code == 42
  end

  def self.makeConsistent(file)
		if !self.consistent?(file)
			inconsistent_data = file.gsub(/\.txt/, '_original.txt')
		
			# backup original discretized data
			File.copy(file, inconsistent_data)
			
			self.run_macaulay("incons.m2", "makeConsistent(///#{inconsistent_data}///, ///#{file}///)")
			
			if (File.zero?(file))
				raise RuntimeError.new("make consistent failed")
			end
		end
  end
end
