module React

  def run(n_nodes, file_prefix, datafiles)
    managerfile = "public/perl/" + file_prefix +".fileman.txt";
    functionfile = "public/perl/" + file_prefix +".functions.txt";
    write_manager_file(managerfile, n_nodes, file_prefix, datafiles);
    run_react(managerfile, modelfile);
    parse_output(modelfile, functionfile);
  end

  def run_react(managerfile, modelfile)
    return "Successfully calling react lib";
  end
  
  def parse_output(infile, outfile)
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
