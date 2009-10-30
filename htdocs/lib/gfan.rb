class Gfan 

  def self.run(discretized_file, functionfile, nodes, pvalue)

      Macaulay.run("sgfan.m2", "sgfan(///#{File.join(RAILS_ROOT, discretized_file)}///, ///#{File.join(RAILS_ROOT, functionfile)}///, #{pvalue}, #{nodes})")
    
  end
