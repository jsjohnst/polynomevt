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
    
    n_react_threshold = -1; # disabling this for now since we don't have it coded yet
    generate_picture = false
    
    if @job.show_wiring_diagram || @job.show_functions
      dotfile = "public/perl/" + @job.file_prefix + ".wiring-diagram.txt"
      graphfile = "public/perl/" + @job.file_prefix + ".wiring-diagram." + @job.wiring_diagram_format
      functionfile = "public/perl/" + @job.file_prefix + ".functionfile.txt"
      consistent_datafile = "public/perl/" + @job.file_prefix + ".consistent-input.txt"
      
      if @job.show_wiring_diagram && !@job.show_functions
        if @job.nodes <= n_react_threshold
          if !macaulay("isConsistent.m2", "isConsistent(///../htdocs/#{discretized_file}///, #{@job.pvalue}, #{@job.nodes})")
            @logger.info "Running react"
            # TODO: make this work -- run_react(@job.nodes, @job.file_prefix, discretized_datafiles)
            generate_picture = true
          else
            macaulay("wd.m2", "wd(///../htdocs/#{discretized_file}///, ///../htdocs/#{dotfile}///, #{@job.pvalue}, #{@job.nodes})")
            `dot -T #{@job.wiring_diagram_format} -o #{graphfile} #{dotfile}`
          end
        else
          self.check_and_make_consistent(datafile, consistent_datafile, discretized_file)
          macaulay("minsets-web.m2", "minsetsWD(///../htdocs/#{discretized_file}///, ///../htdocs/#{dotfile}///, #{@job.pvalue}, #{@job.nodes})")
          `dot -T #{@job.wiring_diagram_format} -o #{graphfile} #{dotfile}`
        end
      else
        if @job.make_deterministic_model
          if @job.nodes <= n_react_threshold
            # TODO: make this work -- run_react(@job.nodes, @job.file_prefix, discretized_datafiles)
            generate_picture = true
          else
            self.check_and_make_consistent(datafile, consistent_datafile, discretized_file)
            macaulay("minsets-web.m2", "minsetsPDS(///../htdocs/#{discretized_file}///, ///../htdocs/#{functionfile}///, #{@job.pvalue}, #{@job.nodes})")
            generate_picture = true
          end
        else # stochastic
          self.check_and_make_consistent(datafile, consistent_datafile, discretized_file)
          macaulay("func.m2", "sgfan(///../htdocs/#{discretized_file}///, ///../htdocs/#{functionfile}///, #{@job.pvalue}, #{@job.nodes})")
          generate_picture = true
        end
      end
    end
    
    if generate_picture
      @logger.info "Starting simulation of state space."
      
      show_probabilities_state_space = @job.show_probabilities_state_space ?  "1" : "0" 
      wiring_diagram = @job.show_wiring_diagram ? "1" : "0" 
      state_space = @job.show_state_space ? "1" : "0" 

      # for synchronous updates or stochastic sequential updates
      if (!@job.sequential? || @job.update_schedule == "" )
          @job.update_schedule = "0"
      end 
      
      # for stochastic sequential updates, sequential has to be set to 0        
      # for dvd_stochastic_runner.pl to run correctly 
      stochastic_sequential_update = "0" 
      if (@job.sequential? && @job.update_schedule == "0")            
        stochastic_sequential_update = "1"             
        @job.update_type = ''
      end 
  
      sequential = @job.sequential? ? "1" : "0" 

      # concatenate update schedule into one string with _ as separators
      # so we can pass it to dvd_stochastic_runner.pl
      @job.update_schedule = @job.update_schedule.gsub(/\s+/, "_" )
      @logger.info "Update Schedule :" + @job.update_schedule + ":"
      @logger.info "Functionfile : " + functionfile

      @logger.info "perl ../perl/dvd_stochastic_runner.pl -v #{@job.nodes} #{@job.pvalue} 1 #{stochastic_sequential_update} public/perl/#{@job.file_prefix} #{@job.state_space_format} #{@job.wiring_diagram_format} #{wiring_diagram} #{state_space} #{sequential} #{@job.update_schedule} #{show_probabilities_state_space} 1 0 #{functionfile}"

      simulation_output = `perl ../perl/dvd_stochastic_runner.pl #{@job.nodes} #{@job.pvalue} 1 #{stochastic_sequential_update} public/perl/#{@job.file_prefix} #{@job.state_space_format} #{@job.wiring_diagram_format} #{wiring_diagram} #{state_space} #{sequential} #{@job.update_schedule} #{show_probabilities_state_space} 1 0 #{functionfile}`
      @logger.info "simulation output: " + simulation_output
    end
      
    # we succeeded if we got to here!
    self.success()
  end  
  
  def check_and_make_consistent(datafile, consistent_datafile, discretized_file)
    if !macaulay("isConsistent.m2", "isConsistent(///../htdocs/#{discretized_file}///, #{@job.pvalue}, #{@job.nodes})")
      self.macaulay("incons.m2", "makeConsistent(///../htdocs/#{datafile}///, #{@job.nodes}, ///../htdocs/#{consistent_datafile}///)")
      if (File.zero?(consistent_datafile))
        # TODO: make a way to store errors into the job for the user to see
        self.abort()
      end
      # backup original input data
      File.copy(datafile, "public/" + @job.file_prefix + ".original-input.txt") 
      # copy consistent data into input and rediscretize
      File.copy(consistent_datafile, "public/" + @job.file_prefix + ".input.txt") 
      self.macaulay("Discretize.m2", "discretize(///../htdocs/#{datafile}///, 0, ///../htdocs/#{discretized_file}///);")
    end
  end
  
  def macaulay(m2_file, m2_command)
    @logger.info "cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e \"#{m2_command} exit 0;\"; cd ../htdocs;"
    @logger.info `cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e "#{m2_command} exit 0;"; cd ../htdocs;`
    $? == 0
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
