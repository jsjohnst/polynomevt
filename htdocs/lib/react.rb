module React

  def run_react(n_nodes, file_prefix, datafiles)
    @react_logger = Logger.new(File.join(RAILS_ROOT, 'log', 'react.log'))
    managerfile = "public/" + file_prefix +".fileman.txt"
    modelfile = "public/" + file_prefix +".model.txt"
    functionfile = "public/" + file_prefix +".functionfile.txt"
    multiplefunctionfile = "public/" + file_prefix +".multiplefunctionfile.txt"
    write_manager_file(managerfile, n_nodes, file_prefix, datafiles)
    run(managerfile, modelfile)
    parse_output(modelfile, functionfile, multiplefunctionfile)
    @react_logger.info "Done with react"
  end

  def run(managerfile, modelfile)
    @react_logger.info "Successfully calling react lib in run:"
    @react_logger.info "../EA/React #{managerfile} #{modelfile}"
    @react_logger.info `cd ../EA; ./React ../htdocs/#{managerfile} ../htdocs/#{modelfile}`
    @react_logger.info "done react lib in run:"
  end
  
  def parse_output(infile, outfile, long_outfile)
    @react_logger.info "in parse output file"
    @react_logger.info "infile #{infile}"
    @react_logger.info "outfile #{outfile}"
    @react_logger.info "long_outfile #{long_outfile}"
    unless File.exists?(infile) 
      @react_logger.info "#{infile} does not exists"
      return
    end
    File.open(long_outfile, 'w') do |long_out_file|
      File.open(outfile, 'w') do |out_file|
        File.open(infile, 'r') do |file|
          # write the top 10 models into the file
          for i in 1..10 do 
            line = file.gets
            @react_logger.info "model.txt \# #{line}"
            unless (line.match( /^Model/ ))
                @react_logger.info "ERROR: React did not create a model file starting with Model."
                return
            end
            while line = file.gets
                @react_logger.info "model.txt Model #{i}"
                if (line.match( /^\s*f/ ))
                    @react_logger.info "Line matches fx"
                    long_out_file.write(line)
                    if i == 1
                      out_file.write(line)
                    end
                elsif (line.match( /^\s*H/ ))
                    @react_logger.info "Line matches H"
                elsif (line.match( /^\s*$/))
                    @react_logger.info "Line matches newline"
                    long_out_file.write(line)
                    break
                else
                    @react_logger.info "ERROR: Reacht parsing models file: Line doesn't match anything"
                    return
                end
            end
          end
        end
      end
    end
  end


# n_nodes, file_prefix, list_of_datafiles
  def write_manager_file(managerfile, n_nodes, file_prefix, datafiles)
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
    datafiles.each  do |dataf| 
        unless (first)  
            file_string = file_string + ","
        end
        first = false
        file_string = file_string + "\"../htdocs/" + dataf + "\""  
    end
    @react_logger.info "file_string in EA: " + file_string

    File.open( managerfile, 'w' ) do |file| 
        
        data = "P=2; N=#{n_nodes};
WT = {#{file_string}};
KO = {};
REV = {};
CMPLX = {};
BIO = {};
MODEL = {};
PARAMS = {\"params.txt\"};"
        file.write(data)
    end

  end
end
