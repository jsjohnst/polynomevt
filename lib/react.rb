module React

  def run_react(n_nodes, file_prefix, datafiles)
    managerfile = "public/perl/" + file_prefix +".fileman.txt"
    modelfile = "public/perl/" + file_prefix +".model.txt"
    functionfile = "public/perl/" + file_prefix +".functionfile.txt"
    write_manager_file(managerfile, n_nodes, file_prefix, datafiles)
    run(managerfile, modelfile)
    # FBH for testing using already generated file
    modelfile = "EA/test4/model_for_testing_ruby.txt"
    parse_output(modelfile, functionfile)
  end

  def run(managerfile, modelfile)
    logger.info "Successfully calling react lib"
    return "Successfully calling react lib"
  end
  
  def parse_output(infile, outfile)
    File.open(outfile, 'w') do |out_file|
      File.open(infile, 'r') do |file|
        line = file.gets
        logger.info "model.txt \# #{line}"
        unless (line.match( /^Model/ ))
            logger.info "ERROR: React did not create a model file starting with Model."
            return
        end
        while line = file.gets
            logger.info "model.txt \# #{line}"
            if (line.match( /^\s*f/ ))
                logger.info "Line matches fx"
                out_file.write(line)
            elsif (line.match( /^\s*H/ ))
                logger.info "Line matches H"
            elsif (line.match( /^\s*$/))
                logger.info "Line matches newline"
                break
            else
                logger.info "ERROR: Reacht parsing models file: Line doesn't match anything"
                return
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


    file_string = ""; 
    
    data = "P=2;
    N=#{n_nodes};
    WT = {\"#{file_string}\"};
    KO = {};
    REV = {};
    CMPLX = {};
    BIO = {};
    MODEL = {};
    PARAMS = {\"params.txt\"};"
    File.open(managerfile, 'w') { |file| file.write(data) }

  end
end
