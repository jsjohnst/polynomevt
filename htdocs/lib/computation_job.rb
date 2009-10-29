require 'digest/md5'
require 'ftools'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'dvdcore'
require 'react'

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

    discretized_file = "public/" + @job.file_prefix + ".discretized_input.txt"
    
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
    
    macaulay("Discretize.m2", "discretize(///#{File.join(RAILS_ROOT, datafile)}///, 0, ///#{File.join(RAILS_ROOT, discretized_file)}///)")
    
    n_react_threshold = 5;
    generate_picture = false
    
    if @job.show_wiring_diagram || @job.show_functions
      wiring_diagram_dotfile = "public/" + @job.file_prefix + ".wiring_diagram.dot"
      wiring_diagram_graphfile = "public/" + @job.file_prefix + ".wiring_diagram." + @job.wiring_diagram_format
      state_space_dotfile = "public/" + @job.file_prefix + ".state_space.dot"
      state_space_graphfile = "public/" + @job.file_prefix + ".state_space." + @job.state_space_format
      functionfile = "public/" + @job.file_prefix + ".functionfile.txt"
      consistent_datafile = "public/" + @job.file_prefix + ".consistent_input.txt"
      
      if @job.show_wiring_diagram && !@job.show_functions
        if @job.nodes <= n_react_threshold
          if !macaulay("isConsistent.m2", "isConsistent(///#{File.join(RAILS_ROOT, discretized_file)}///, #{@job.pvalue}, #{@job.nodes})", true)
            react = React.new(File.join(RAILS_ROOT, 'public', @job.file_prefix), @job.nodes)
            react.discretized_data_file = discretized_file
            react.run
            generate_picture = true
          else
            # TODO
            @logger.info "judging from the flow chart we're supposed to use
            wd, but wd has not been rewritten to use a file with hashes
            instead of a list"
            macaulay("wd.m2", "wd(///#{File.join(RAILS_ROOT, discretized_file)}///, ///#{File.join(RAILS_ROOT, wiring_diagram_dotfile)}///, #{@job.pvalue}, #{@job.nodes})")
            `dot -T #{@job.wiring_diagram_format} -o #{wiring_diagram_graphfile} #{wiring_diagram_dotfile}`
          end
        else
          self.check_and_make_consistent(datafile, consistent_datafile, discretized_file)
          @logger.info "running minsetsWD"
          macaulay("minsets-web.m2", "minsetsWD(///#{File.join(RAILS_ROOT, discretized_file)}///, ///#{File.join(RAILS_ROOT, wiring_diagram_dotfile)}///, #{@job.pvalue}, #{@job.nodes})")
          `dot -T #{@job.wiring_diagram_format} -o #{wiring_diagram_graphfile} #{wiring_diagram_dotfile}`
        end
      else
        if @job.make_deterministic_model
          @logger.info "deterministic"
          if @job.nodes <= n_react_threshold
            react = React.new(File.join(RAILS_ROOT, 'public', @job.file_prefix), @job.nodes)
            react.discretized_data_file = discretized_file
            react.run
            generate_picture = true
          else
            self.check_and_make_consistent(datafile, consistent_datafile, discretized_file)
            @logger.info "running minsetsPDS"
            macaulay("minsets-web.m2", "minsetsPDS(///#{File.join(RAILS_ROOT, discretized_file)}///, ///#{File.join(RAILS_ROOT, functionfile)}///, #{@job.pvalue}, #{@job.nodes})")
            generate_picture = true
          end
        else # stochastic
          @logger.info "stochastic"
          self.check_and_make_consistent(datafile, consistent_datafile, discretized_file)
          macaulay("sgfan.m2", "sgfan(///#{File.join(RAILS_ROOT, discretized_file)}///, ///#{File.join(RAILS_ROOT, functionfile)}///, #{@job.pvalue}, #{@job.nodes})")
          generate_picture = true
        end
      end
    end
    
    if generate_picture
      @logger.info "Starting simulation of state space."
      
      @logger.info "Functionfile : " + functionfile

      unless File.exists?(functionfile) 
        @logger.info "Functionfile has not been written so we can't run dvd_stochastic_runner on it. "
        self.abort()
      end

      dvd = DVDCore.new(File.join(RAILS_ROOT, 'public', @job.file_prefix), @job.nodes, @job.pvalue)
      dvd.create_wiring_diagram = @job.show_wiring_diagram
      dvd.create_state_space = @job.show_state_space
      dvd.show_probabilities = @job.show_probabilities_state_space
      dvd.run

      simulation_output = "Fixed points: #{dvd.fixed_points}"
      @logger.info simulation_output
      
      if @job.show_wiring_diagram
        unless File.exists?(wiring_diagram_dotfile)
          @logger.info "Wiring diagram dotfile has not been written."
          self.abort() 
        end
        `dot -T #{@job.wiring_diagram_format} -o #{File.join(RAILS_ROOT, wiring_diagram_graphfile)} #{File.join(RAILS_ROOT, wiring_diagram_dotfile)}`  
      end

      if @job.show_state_space
        unless File.exists?(state_space_dotfile)
          @logger.info "Wiring diagram dotfile has not been written."
          self.abort() 
        end
        `dot -T #{@job.state_space_format} -o #{File.join(RAILS_ROOT, state_space_graphfile)} #{File.join(RAILS_ROOT, state_space_dotfile)}`  
      end

    end
      
    # we succeeded if we got to here!
    self.success()
  end  
  
  def check_and_make_consistent(datafile, consistent_datafile, discretized_file)
    if !macaulay("isConsistent.m2", "isConsistent(///#{File.join(RAILS_ROOT, discretized_file)}///, #{@job.pvalue}, #{@job.nodes})", true)
      self.macaulay("incons.m2", "makeConsistent(///#{File.join(RAILS_ROOT, datafile)}///, #{@job.nodes}, ///#{File.join(RAILS_ROOT, consistent_datafile)}///)")
      if (File.zero?(consistent_datafile))
        # TODO: make a way to store errors into the job for the user to see
        self.abort()
      end
      # backup original input data
      File.copy(datafile, "public/" + @job.file_prefix + ".original-input.txt") 
      # copy consistent data into input and rediscretize
      File.copy(consistent_datafile, "public/" + @job.file_prefix + ".input.txt") 
      self.macaulay("Discretize.m2", "discretize(///#{File.join(RAILS_ROOT, datafile)}///, 0, ///#{File.join(RAILS_ROOT, discretized_file)}///)")
    end
  end
 
  # we do the continue_on_error optionally because we want to sometimes
  # check the return value of a command normally (ie isConsistent) but
  # in most cases we want to just exit on m2 failure
  def macaulay(m2_file, m2_command, continue_on_error = false)
    @logger.info "cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e \"#{m2_command}; exit 0;\"; cd ../htdocs;"
    @logger.info `cd ../macaulay/; M2 #{m2_file} --stop --no-debug --silent -q -e "#{m2_command}; exit 0;"; cd ../htdocs;`
    if continue_on_error && $? != 0
       @logger.info "Macaulay (#{m2_file}) (#{m2_command}) returned a non-zero exit code (#{$?}), aborting."
       self.abort
    end
    $? == 0
  end
  
  def abort
    @job.failed = true
    self.completed
  end

  def create_zip
    zip_filename = "public/" + @job.file_prefix + ".job.zip"

    # check to see if the file exists already, and if it does, delete it.
    if File.file?(zip_filename)
    	File.delete(zip_filename)
    end

    Zip::ZipFile.open(zip_filename, Zip::ZipFile::CREATE) { |zipfile|
	zipfile.mkdir("job-" + @job.id.to_s)
	Dir.glob("public/" + @job.file_prefix + ".*") { |filename|
		zipfile.add(filename.gsub(/public\/#{@job.file_prefix}\./, "job-" + @job.id.to_s + "/"), filename);
	}	
    }

    # set read permissions on the file
    File.chmod(0644, zip_filename)
  end
  
  def success
    self.create_zip
    @job.failed = false
    self.completed
  end
  
  def completed
    @job.completed = true
    @job.save
  end
end
