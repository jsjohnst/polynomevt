require 'digest/md5'
require 'ftools'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'dvdcore'
require 'react'
require 'algorithm'
require 'discretize'
require 'data_integrity'
require 'generate_wiring_diagram'
require 'parameter_estimation'

class ComputationJob < Struct.new(:job_id)  
  def perform
    begin  
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
			Algorithm.logger = @logger    
			Algorithm.job = @job

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
			
		  Discretize.run(File.join(RAILS_ROOT, datafile), File.join(RAILS_ROOT, discretized_file))
	
			if @job.show_wiring_diagram || @job.show_functions
				wiring_diagram_dotfile = "public/" + @job.file_prefix + ".wiring_diagram.dot"
				wiring_diagram_graphfile = "public/" + @job.file_prefix + ".wiring_diagram." + @job.wiring_diagram_format
				state_space_dotfile = "public/" + @job.file_prefix + ".state_space.dot"
				state_space_graphfile = "public/" + @job.file_prefix + ".state_space." + @job.state_space_format
				functionfile = "public/" + @job.file_prefix + ".functionfile.txt"
				consistent_datafile = "public/" + @job.file_prefix + ".consistent_input.txt"
			
				@original_file_prefix = @job.file_prefix	
				Algorithm.job.file_prefix = File.join(RAILS_ROOT, 'public', @job.file_prefix)
				
				if @job.show_wiring_diagram && !@job.show_functions
					GenerateWiringDiagram.run(File.join(RAILS_ROOT, discretized_file), File.join(RAILS_ROOT, wiring_diagram_dotfile))
				else
					ParameterEstimation.run(File.join(RAILS_ROOT, discretized_file), File.join(RAILS_ROOT, functionfile))
				end
			end
			
			@logger.info "Functionfile : " + functionfile

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
				
			# we succeeded if we got to here!
			self.success()
	
  	rescue => exc 
			@logger.info "Something threw an exception, aborting"
			self.abort()
			raise exc
		end
  end  
  
  def check_and_make_consistent(datafile, consistent_datafile, discretized_file)
    if !DataIntegrity.consistent?(File.join(RAILS_ROOT, discretized_file))
			DataIntegrity.makeConsistent(File.join(RAILS_ROOT, datafile), File.join(RAILS_ROOT, consistent_datafile))
      if (File.zero?(consistent_datafile))
        # TODO: make a way to store errors into the job for the user to see
        self.abort()
      end
      # backup original input data
      File.copy(datafile, "public/" + @job.file_prefix + ".original-input.txt") 
      # copy consistent data into input and rediscretize
      File.copy(consistent_datafile, "public/" + @job.file_prefix + ".input.txt") 
		  Discretize.run(File.join(RAILS_ROOT, datafile), File.join(RAILS_ROOT, discretized_file))
    end
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
		@job.file_prefix = @original_file_prefix
    @job.completed = true
    @job.save
  end
end
