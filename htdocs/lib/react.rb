
class React < Struct.new(:file_prefix, :nodes)
  attr_accessor :discretized_data_file
  
  MANAGERFILE_SUFFIX = ".fileman.txt"
  PARAMETER_SUFFIX = ".params.txt"
  MODELFILE_SUFFIX = ".model.txt"
  FUNCTIONFILE_SUFFIX = ".functionfile.txt" 
  MULTIPLEFUNCTIONFILE_SUFFIX = ".multiplefunctionfile.txt"

  def run
    @react_logger = Logger.new(File.join(RAILS_ROOT, 'log', 'react.log'))
    if write_manager_file && execute_react && parse_output 
       @react_logger.info "Done with react"
       return true
    else
       @react_logger.info "React failed (returned non-zero status)!"
       return false
    end
  end

  def execute_react
    @react_logger.info "Successfully calling react lib in run:"
    @react_logger.info "cd ../EA; ./React #{file_prefix + MANAGERFILE_SUFFIX} #{file_prefix + MODELFILE_SUFFIX}"
    @react_logger.info `cd ../EA; ./React #{file_prefix + MANAGERFILE_SUFFIX} #{file_prefix + MODELFILE_SUFFIX}`
    @react_logger.info "done react lib in run:"
    $? == 0
  end
  
  def parse_output
    @react_logger.info "in parse output file"
    unless File.exists?( file_prefix + MODELFILE_SUFFIX ) 
      @react_logger.info "#{file_prefix + MODELFILE_SUFFIX} does not exists"
      return FALSE
    end
    File.open(file_prefix + MULTIPLEFUNCTIONFILE_SUFFIX, 'w') do |multiple_function_file|
      File.open(file_prefix + FUNCTIONFILE_SUFFIX, 'w') do |function_file|
        File.open(file_prefix + MODELFILE_SUFFIX, 'r') do |model_file|
          # write the top 10 models into the file
          for i in 1..10 do 
            line = model_file.gets
            @react_logger.info "model.txt \# #{line}"
            unless (line.match( /^Model/ ))
                @react_logger.info "ERROR: React did not create a model file starting with Model."
                return FALSE
            end
            while line = model_file.gets
                @react_logger.info "model.txt Model #{i}"
                if (line.match( /^\s*f/ ))
                    @react_logger.info "Line matches fx"
                    multiple_function_file.write(line)
                    if i == 1
                      function_file.write(line)
                    end
                elsif (line.match( /^\s*H/ ))
                    @react_logger.info "Line matches H"
                elsif (line.match( /^\s*$/))
                    @react_logger.info "Line matches newline"
                    multiple_function_file.write(line)
                    break
                else
                    @react_logger.info "ERROR: React parsing models file: Line doesn't match anything"
                    return FALSE
                end
            end
          end
        end
      end
    end
    TRUE
  end


  def write_manager_file
  ## Needs to look like this 
	## P=2;
	## N=8;
	## WT = {"w1.txt","w2.txt"};
	## KO = {};
	## REV = {};
	## CMPLX = {};
	## BIO = {};
	## MODEL = {};
	## PARAMS = {"params1.txt"};

    file_string = ''  
    first = true
    discretized_data_files = discretized_data_file
    discretized_data_files.each  do |dataf| 
        unless (first)  
            file_string = file_string + ","
        end
        first = false
        file_string = file_string + "\"" + dataf + "\""  
    end
    @react_logger.info "file_string in EA: " + file_string

    File.open( file_prefix + MANAGERFILE_SUFFIX, 'w' ) do |file| 
        
        data = "P=2; N=#{nodes};
WT = {#{file_string}};
KO = {};
REV = {};
CMPLX = {};
BIO = {};
MODEL = {};
PARAMS = {\"params.txt\"};"
        file.write(data)
    end
    TRUE
  end

end
