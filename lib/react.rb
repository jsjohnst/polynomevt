module React

  def run_react(n_nodes, datafiles)
    return "Successfully calling react lib";
  end
  
  def parse_output(infile, outfile)
  end


# n_nodes, file_prefix
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

    filemanagerfile = "EA/" + @file_format +".fileman.txt";
    data = "P=2;
    N=#{n_nodes};
    WT = {"w1.txt","w2.txt"};
    KO = {};
    REV = {};
    CMPLX = {};
    BIO = {};
    MODEL = {};
    PARAMS = {\"params.txt\"};"
    File.open(filemanagerfile, 'w') { |file| file.write(data) }

  end
end
