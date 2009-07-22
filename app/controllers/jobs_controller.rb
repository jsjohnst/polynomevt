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
    @job = Job.new(:is_deterministic => false, :nodes => 3, :input_data => 
    "# First time course 
1.2  2.3  3.4
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
    if (@job.valid?)
        logger.info "job.valid? " + @job.valid?.to_s;  
        # create the dummy file to avoid RouteErrors
        self.write_done_file("0", "");
    else 
        logger.info "job.valid? " + @job.valid?.to_s;  
        self.write_done_file("2", "Please check the data you input.");
        return;
    end

    params[:job].each { | key, value |
      ENV['POLYNOME_' + key.upcase] = value;
    }
    # create file prefix using md5 check sum as part of the filename
    ENV['POLYNOME_FILE_PREFIX'] = 'files/files-' +
    Digest::MD5.hexdigest(params[:job][:input_data]);
    logger.info "fileprefix: "+ ENV['POLYNOME_FILE_PREFIX'];
    @file_prefix = ENV['POLYNOME_FILE_PREFIX'];

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
        @error_message = "The data you entered is invalid.";
        self.write_done_file("2", "<font color=red>" +  @error_message + "</font><br> "); 
        @error_message = "";
        return; 
    end
    
    # create the dummy file to avoid RouteErrors
    self.write_done_file("0", "");

    n_react_threshold = 5;
    n_stochastic_threshold = 10;
    
    ## All checking of any input should be done before we spawn, so the user
    #receives feedback about invalid options right away and not after some time
    # ( = everything) 
    if !@job.is_deterministic && @job.nodes > n_stochastic_threshold
      @error_message = "A stochastic model requires no more than #{n_stochastic_threshold} nodes.  Sorry!";
      self.write_done_file("2", "<font color=red>" +  @error_message + "</font><br> ");
      @error_message = "";
      return;
    end
    
    # check for correct input options
    logger.info "Sequential update: " + @job.sequential.to_s;
    stochastic_sequential_update = "0";
    if (@job.sequential)
        logger.info "Update_schedule :" +@job.update_schedule + ":";
        if ( !@job.is_deterministic )
            logger.info "Not deterministic";
            @error_message = "Sequential updates can only be chosen for deterministic models. Exiting";
            self.write_done_file("2", "<font color=red>" +  @error_message+ "</font><br> "); 
            return;
        end
        if ( @job.update_schedule == "")
            logger.info "Update sequential but no schedule given, doing
            sequential udpate with random update schedule";
            stochastic_sequential_update = "1";
        end
    end
   
    ## TODO FBH Need to check update schedule for correctness 

    spawn do
        #TODO this will change to a single new filename
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

      # react: n <= n_threshold, is_deterministic
      # minsets: n > n_threshold, is_deterministic
      # sgfan: n <= n_threshold, !is_deterministic, data_consistent
      # error: all other cases, i.e. n > n_threshold, !is_deterministic, !data_consistent

      if @job.state_space
        @job.show_functions = true;
        @functionfile_name = self.functionfile_name(@file_prefix);
      end
      
      if !@job.show_functions && !@job.wiring_diagram
        self.write_done_file("1", "Thats all folks!");
        return;
      end
      
      do_wiring_diagram_version = @job.wiring_diagram && !@job.show_functions;
      # if function file is not needed, then run shorter version of minset/sgfan
      #    which produces a wiring diagram but not a function file.
      
      if @job.is_deterministic
        if @job.nodes <= n_react_threshold
          # do react
          run_react(@job.nodes, discretized_datafiles);
        else
          # do: makeconsistent, minsets
          self.make_data_consistent(discretized_datafiles, @p_value, @job.nodes);
          if do_wiring_diagram_version
            self.minsets_generate_wiring_diagram(discretized_datafiles,
                @job.wiring_diagram_format, @p_value, @job.nodes);
          else
            self.minsets(discretized_datafiles, @p_value, @job.nodes);           
          end
        end
      else 
        self.make_data_consistent(discretized_datafiles, @p_value, @job.nodes);
        if @job.nodes <= n_stochastic_threshold
          # do sgfan
          if do_wiring_diagram_version
            self.generate_wiring_diagram(discretized_datafiles,
                @job.wiring_diagram_format, @p_value, @job.nodes);
          else
            self.sgfan(discretized_datafiles, @p_value, @job.nodes);
          end
        else
          logger.warn("internal error: should not be here")
        end
      end
      
      self.write_done_file("1", ""); 
      
      if !do_wiring_diagram_version
          # run simulation
          logger.info "Starting simulation of state space.";
            
          if ( @job.sequential && !@job.update_schedule )
              logger.info "Update sequential but no schedule given, doing
              sequential udpate with random update schedule";
              stochastic_sequential_update = "1";
          end
          
          show_probabilities_state_space = @job.show_probabilities_state_space ?  "1" : "0";
          wiring_diagram = @job.wiring_diagram ? "1" : "0";
          sequential = @job.sequential ? "1" : "0";

          if ( !@job.update_schedule || @job.update_schedule == "") 
            @job.update_schedule = "0";
          else 
            # concatenate update schedule into one string with _ as separators
            # so we can pass it to dvd_stochastic_runner.pl
            @job.update_schedule = @job.update_schedule.gsub(/\s+/, "_" );
          end
          logger.info "Update Schedule: " + @job.update_schedule;


          simulation_output = `perl public/perl/dvd_stochastic_runner.pl #{@job.nodes} #{@p_value.to_s} 1 #{stochastic_sequential_update} public/perl/#{@file_prefix} #{@job.state_space_format} #{@job.wiring_diagram_format} #{wiring_diagram} #{sequential} #{@job.update_schedule} #{show_probabilities_state_space} 1 0 #{@functionfile_name}`;
          simulation_output = simulation_output.gsub("\n", "");
      end
      
      self.write_done_file("1",  simulation_output);
    end
  end
 
  def write_done_file(done, simulation_output)
    # Tell the website we are done
    `echo 'var done = #{done};' > public/perl/#{@file_prefix}.done.js`;
    `echo "var simulation_output = '#{simulation_output}';" >> public/perl/#{@file_prefix}.done.js`;
  end
  
  # TODO FBH: This function is doing the checking at the moment, should
  # probably restructure 
  # We won't need this function anymore as soon as Brandy has rewritten M2
  # code to accept single file with #
  # This should only do the error checking! 
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
            if( line.match( /^\s*\#+/ ) )
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
 


 # 
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

    logger.info macaulay2(
      :m2_command => "wd(#{m2_string(discretized_data_files)}, ///../#{dotfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "wd.m2",
      :post_m2_command => "dot -T #{file_format} -o #{graphfile} #{dotfile}",
      :m2_wait => 1
      );
  end

  def minsets_generate_wiring_diagram(discretized_data_files, file_format, p_value, n_nodes)
    dotfile = self.dotfile_name(@file_prefix);
    graphfile = self.graphfile_name(@file_prefix, file_format);

    macaulay2(
      :m2_command => "minsetsWD(#{m2_string(discretized_data_files)}, ///../#{dotfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "minsets-web.m2",
      :post_m2_command => "dot -T #{file_format} -o #{graphfile} #{dotfile}",
      :m2_wait => 1
      );
  end
  
  def data_consistent?(discretized_data_files, p_value, n_nodes)
    ret_val = macaulay2(
      :m2_command => "isConsistent(#{m2_string(discretized_data_files)}, #{p_value}, #{n_nodes})",
      :m2_file => "isConsistent.m2",
      :m2_wait => 1
      );
    # 0 inconsistent
    # 1 consistent
    logger.info "data is consistent returned " + ret_val + "0 inconsistent,
    1 consistent";
    return ( ret_val != "0" );
  end

  def make_data_consistent(discretized_data_files, p_value, n_nodes)
    logger.warn("make_data_consistent is not yet written: always just continues...");
  end

  def sgfan(discretized_data_files, p_value, n_nodes)
    functionfile = self.functionfile_name(@file_prefix);
    macaulay2(
      :m2_command => "sgfan(#{m2_string(discretized_data_files)}, ///../#{functionfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "func.m2",
      :m2_wait => 1
      );
    functionfile;
  end
  
  def minsets(discretized_data_files, p_value, n_nodes)
    functionfile = self.functionfile_name(@file_prefix);
    macaulay2(
      :m2_command => "minsets(#{m2_string(discretized_data_files)}, ///../#{functionfile}///, #{p_value}, #{n_nodes})",
      :m2_file => "minsets-web.m2",
      :m2_wait => 1
      );
    functionfile;
  end
end
