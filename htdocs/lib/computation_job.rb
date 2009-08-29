require 'digest/md5'
require 'ftools'

class ComputationJob < Struct.new(:job_id)  
  def perform  
    # here is where we will handle the background Macaulay processing  
    # and simulation of the network
    
    # first we go fetch the job so we know what we need to do
    @job = Job.find(job_id)
    
    # now we setup a unique path to this job's data
    @job.file_prefix = 'files/files-' + Digest::MD5.hexdigest( @job.id.to_s )
   
    # save input data TODO read from file
    datafile = "public/" + @job.file_prefix + ".input.txt"
    File.open(datafile, 'w') {|file| file.write(@job.input_data) }

    discretized_file = datafile.gsub(/input/, 'discretized_input')
    
    @logger = Logger.new(File.join(RAILS_ROOT, 'log', 'computation_job.log'))
    @logger.info "Discretized_file => " + discretized_file
   
    # clean file of extra white spaces before discretizing
    File.open(datafile, 'r') do |file|
      output  = File.open("public/" + @job.file_prefix + ".tmp.txt", 'w') 
      while line = file.gets
        my_array = line.split
        first = true
        my_array.each do |number|
          puts number
          if first
            output.print number
            first = false
          else
            output.print " " + number
          end
        end
        output.print "\n"
      end
      output.close
    end
    File.copy("public/" + @job.file_prefix + ".tmp.txt", datafile)

    # discretize files
    @logger.info "pwd => " + Dir.getwd
    
    macaulay("Discretize.m2", "discretize(///../htdocs/#{datafile}///, 0, ///../htdocs/#{discretized_file}///);")
    
    
    # if wiring diagram and !show_functions
    
    # m2 code in no particular order, need to move where appropriate
    
    # macaulay("isConsistent.m2", "isConsistent(///../htdocs/#{discretized_file}///, #{@job.pvalue}, #{@job.nodes})")
    
    # dotfile = "public/perl/" + @job.file_prefix + ".wiring-diagram.txt"
    # graphfile = "public/perl/" + @job.file_prefix + ".wiring-diagram." + @job.wiring_diagram_format
    
    # macaulay("wd.m2", "wd(///../htdocs/#{discretized_file}///, ///../htdocs/#{dotfile}///, #{@job.pvalue}, #{@job.nodes})")
    # `dot -T #{@job.wiring_diagram_format} -o #{graphfile} #{dotfile}`
    
    # macaulay("minsets-web.m2", "minsetsWD(///../htdocs/#{discretized_file}///, ///../htdocs/#{dotfile}///, #{@job.pvalue}, #{@job.nodes})")
    # `dot -T #{@job.wiring_diagram_format} -o #{graphfile} #{dotfile}`
    
    # functionfile = "public/perl/" + @job.file_prefix + ".functionfile.txt"
    
    # macaulay("minsets-web.m2", "minsetsPDS(///../htdocs/#{discretized_file}///, ///../htdocs/#{functionfile}///, #{@job.pvalue}, #{@job.nodes})")
    
    
    # macaulay("func.m2", "sgfan(///../htdocs/#{discretized_file}///, ///../htdocs/#{functionfile}///, #{@job.pvalue}, #{@job.nodes})")
    
    
    
    # consistent_datafile = "public/perl/" + @job.file_prefix + ".consistent-input.txt"
    # macaulay("incons.m2", "makeConsistent(///../htdocs/#{datafile}///, #{@job.nodes}, ///../htdocs/#{consistent_datafile}///)")
    # if (File.zero?(consistent_datafile))
    #    TODO: make a way to store errors into the job for the user to see
    #    self.abort()
    # end
    # File.copy(datafile, "public/" + @job.file_prefix + ".original-input.txt")
    # File.copy(datafile, "public/" + @job.file_prefix + ".input.txt")
    # TODO need to rediscretize now
    
    
    
    
    # we succeeded if we got to here!
    self.success()
  end  
  
  def macaulay(m2_file, m2_command)
    @logger.info "cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e \"#{m2_command} exit 0;\"; cd ../htdocs;"
    @logger.info `cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e "#{m2_command} exit 0;"; cd ../htdocs;`
  end
  
  def abort
    @job.failed = true
    self.completed
  end
  
  def success
    @job.failed = false
    self.completed
  end
  
  def completed
    @job.completed = true
    @job.save
  end
end
