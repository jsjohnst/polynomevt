require 'digest/md5'

include React
include Spawn
include Macaulay

class JobsController < ApplicationController
  layout "main"

  def functionfile_name(prefix)
    "public/perl/" + prefix + ".functionfile.txt";
  end
  
  def dotfile_name(prefix)
    "public/perl/" + prefix + ".wiring-diagram.dot";
  end
    
  def graphfile_name(prefix, file_format)
    "public/perl/" + prefix + ".wiring-diagram." + file_format;
  end
  
  def index
    @job = Job.new(:nodes => 3, :input_data => 
    "1.2  2.3  3.4
1.1  1.2  1.3
2.2  2.3  2.4
0.1  0.2  0.3");

    @error_message = params[:error_message];
  end

  def generate
    # Boolean, not multistate yet  
    @p_value = "2";
    if(!params || !params[:job])
      logger.info "Inside Redirect!";
      redirect_to :action => "index";
      return;
    end
    if(params[:job][:input_file])
      logger.info "Reading :input_file into :input_data";
      params[:job][:input_data] = params[:job][:input_file].read;
      params[:job].delete(:input_file);
    end
    @job = Job.new(params[:job]);
    params[:job].each { | key, value |
      ENV['POLYNOME_' + key.upcase] = value;
    }
    # create file prefix using md5 check sum as part of the filename
    ENV['POLYNOME_FILE_PREFIX'] = 'files/files-' +
    Digest::MD5.hexdigest(params[:job][:input_data]);
    logger.info "fileprefix: "+ ENV['POLYNOME_FILE_PREFIX'];
    @file_prefix = ENV['POLYNOME_FILE_PREFIX'];

    # TODO: Fix this!
    `echo 'var data = 1;' > public/perl/#{@file_prefix}.done.js`;

    # MES: need to validate the input file, using n_nodes
    # MES: need to validate n_nodes, p_value
    if (@job.nodes < 1)
        logger.info "Number of nodes too small";
        @error_message = "Number of nodes too small";
        return;
    end
    if (@job.nodes > 11)
        logger.info "Number of nodes too big";
        @error_message = "Number of nodes too big";
        return;
    end
   
    # split is also checking the input format
    datafiles = self.split_data_into_files(params[:job][:input_data]);
    if (!datafiles)
        # TODO make this error message nice
        @error_message = "The data you entered is invalid";
        return; 
    end
        
    discretized_datafiles = datafiles.collect { |datafile|
      datafile.gsub(/input/, 'discretized-input');
    }

    self.discretize_data(datafiles, discretized_datafiles, @p_value);

    
    #concatenate_discretized_files
    first = TRUE;
    File.open( "public/perl/" + @file_prefix + ".discretized-input.txt", 'w') {
        |f| discretized_datafiles.each{ |datafile|
            if (!first)
                f.write("#\n");
            end
            f.write(File.open(datafile, 'r').read);
            first = FALSE;}
   }

    

    if ( @job.wiring_diagram && !@job.state_space && !@job.show_functions )
        # MES: this call to data_consistent? fails currently since we can't get the return val from M2 calls
        if !self.data_consistent?(discretized_datafiles, @p_value, @n_nodes)
            # here we somehow give the error that the data is not consistent.
            flash[:notice] = "discretized data is not consistent";
            logger.info "Discretized data not consistent, need to implement
            EA or make data consistent? Nore sure yet.";
            return;
        else
            flash[:notice] = "discretized data is consistent";
            if ( @job.nodes <= 10 ) 
                self.generate_wiring_diagram(discretized_datafiles,
                    @job.wiring_diagram_format, @p_value, @job.nodes);
            else 
                self.minsets_generate_wiring_diagram(discretized_datafiles,
                    @job.wiring_diagram_format, @p_value, @job.nodes);
            end
        end
        # There's nothing else here to do
        return;
    end

    if (@job.show_functions || @job.state_space )
         if (@job.is_deterministic)
            if (@job.nodes <= 4 )
                @error_message = run( @job.nodes, discretized_datafiles );
                logger.info "EA is not implemented yet";
                @error_message += "<br>We're calling EA here but don't have the
                right config file yet. Be patient!<br>";
            # else this has to be changed to an else once EA is implemented
                logger.info "Using minsets to generate the functions";
                # TODO FBH need to check data for consistency and run make
                # consistent
                @functionfile_name = self.minsets(discretized_datafiles, @p_value, @job.nodes);
            end
        else
            @functionfile_name = self.sgfan(discretized_datafiles, @p_value, @job.nodes);
        end
    end
   
    # TODO FBH need to wait for sgfan() to be done
    if (@job.state_space)
        # run simulation
        logger.info "Starting stochastic_runner";

        show_probabilities_state_space = @job.show_probabilities_state_space ?  "1" : "0";
        wiring_diagram = @job.wiring_diagram ? "1" : "0";

        @simulation_output = `perl public/perl/dvd_stochastic_runner.pl #{@job.nodes} #{@p_value.to_s} 1 0 public/perl/#{@file_prefix} #{@job.state_space_format} #{@job.wiring_diagram_format} #{wiring_diagram} 0 0 #{show_probabilities_state_space} 1 0 #{@functionfile_name}`;

        #spawn do 
        #    @perl_output = `./polynome.pl #{@job.nodes}`
        #end
    end
  end
  
  # TODO FBH: This function is doing the checking at the moment, should
  # probably restructure 
  def split_data_into_files(data)
    datafile = "public/perl/" + @file_prefix + ".input.txt";

    File.open(datafile, 'w') {|f| f.write(data) }

    datafiles = [];
    output = NIL;
    File.open(datafile) do |file| 
        counter = 0;
        something_was_written = FALSE;
        while line = file.gets 
            # parse lines and break into different files at #
            if( line.match( /^\s*\#+\s*$/ ) )
                if (something_was_written && output) 
                    output.close;
                    output = NIL;
                end
                something_was_written = FALSE;
            else 
                if (!something_was_written) 
                    outputfile_name = datafile.gsub(/input/,"input" +
                    counter.to_s);
                    counter +=1;
                    output = File.open(outputfile_name, "w"); 
                    datafiles.push(Dir.getwd + "/" + outputfile_name);
                end
                # check if line matches @n_nodes digits
                nodes_minus_one = (@job.nodes - 1).to_s;
                if (line.match( /^\s*(\.?\d+\.?\d*\s+){#{nodes_minus_one}}\.?\d+\.?\d*\s*$/ ) ) 
                    output.puts line;
                    logger.info "write line" + line;
                    something_was_written = TRUE;
                else
                    logger.warn "Error: Input data not correct";
                    return NIL;
                end
            end
        end 
        file.close;
        if (output) 
            output.close;
        end
    end
    return datafiles;
  end
  
  def discretize_data(infiles, outfiles, p_value)    
    # infiles: list of input file names to be discretized together
    # outfiles: the names of the output discretized files.  The length
    #    of infiles and outfiles should be identical.
    macaulay2(
      :m2_command => "discretize(#{m2_string(infiles)}, #{m2_string(outfiles)}, #{p_value})",
      :m2_file => "Discretize.m2",
      :m2_wait => 1
      );
  end
  
  def generate_wiring_diagram(discretized_data_files, file_format, p_value, n_nodes)
    dotfile = self.dotfile_name(@file_prefix);
    graphfile = self.graphfile_name(@file_prefix, file_format);

    macaulay2(
      :m2_command => "wd(#{m2_string(discretized_data_files)}, ///../#{dotfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "wd.m2",
      :post_m2_command => "dot -T #{file_format} -o #{graphfile} #{dotfile}"
      );
  end

  def minsets_generate_wiring_diagram(discretized_data_files, file_format, p_value, n_nodes)
    dotfile = self.dotfile_name(@file_prefix);
    graphfile = self.graphfile_name(@file_prefix, file_format);

    macaulay2(
      :m2_command => "minsetsWD(#{m2_string(discretized_data_files)}, ///../#{dotfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "minsets-web.m2",
      :post_m2_command => "dot -T #{file_format} -o #{graphfile} #{dotfile}"
      );
  end
  
  def data_consistent?(discretized_data_files, p_value, n_nodes)
    macaulay2(
      :m2_command => "isConsistent(#{m2_string(discretized_data_files)}, #{p_value}, #{n_nodes})",
      :m2_file => "isConsistent.m2"
      );
  end

  def sgfan(discretized_data_files, p_value, n_nodes)
    functionfile = self.functionfile_name(@file_prefix);
    macaulay2(
      :m2_command => "sgfan(#{m2_string(discretized_data_files)}, ///../#{functionfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "func.m2"
      );
    functionfile;
  end
  
  def minsets(discretized_data_files, p_value, n_nodes)
    functionfile = self.functionfile_name(@file_prefix);
    macaulay2(
      :m2_command => "minsets(#{m2_string(discretized_data_files)}, ///../#{functionfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "minsets-web.m2"
      );
    functionfile;
  end
end
