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
    
    logger = Logger.new(File.join(RAILS_ROOT, 'log', 'computation_job.log'))
    logger.info "Discretized_file => " + discretized_file
   
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
    logger.info "pwd => " + Dir.getwd
    logger.info "cd ../macaulay/; M2 Discretize.m2 --stop --no-debug --silent -q -e \"discretize(///../htdocs/#{datafile}///, 0, ///../htdocs/#{discretized_file}///); exit 0;\"; cd ../htdocs;"
    logger.info "starting macaulay"
    logger.info `cd ../macaulay/; M2 Discretize.m2 --stop --no-debug --silent -q -e "discretize(///../htdocs/#{datafile}///, 0, ///../htdocs/#{discretized_file}///); exit 0;"; cd ../htdocs;`
    
    
    # if wiring diagram and !show_functions
    
    
    
    # we succeeded if we got to here!
    self.success()
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
