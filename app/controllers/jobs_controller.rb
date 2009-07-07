require 'digest/md5'

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
    # FBH:
    
    datafiles = self.split_data_into_files(params[:job][:input_data]);
        
    discretized_datafiles = datafiles.collect { |datafile|
      datafile.gsub(/input/, 'discretized-input');
    }
    
    self.discretize_data(datafiles, discretized_datafiles, @p_value);

    # MES: this call to data_consistent? fails currently since we can't get the return val from M2 calls
    if !self.data_consistent?(discretized_datafiles, @p_value, @n_nodes)
      # here we somehow give the error that the data is not consistent.
      flash[:notice] = "discretized data is not consistent";
    else
      flash[:notice] = "discretized data is consistent";
    end
    self.generate_wiring_diagram(discretized_datafiles,
      @job.wiring_diagram_format, @p_value, @job.nodes);

    @functionfile_name = self.sgfan(discretized_datafiles, @p_value, @job.nodes);
    @functionfile_name = self.minsets(discretized_datafiles, @p_value, @job.nodes);
    
    #spawn do 
    #    @perl_output = `./polynome.pl #{@job.nodes}`
    #end
  end
  
  def split_data_into_files(data)
    datafile = "public/perl/" + @file_prefix + ".input.txt";
    File.open(datafile, 'w') {|f| f.write(data) }
    datafiles = [];
    datafiles.push(Dir.getwd + "/" + datafile);
    return datafiles;
  end
  
  def discretize_data_old(datafiles, discretized_datafiles, p_value)    
    datafiles_string = make_m2_string_from_array(datafiles);
    discretized_datafiles_string = make_m2_string_from_array(discretized_datafiles);

    macaulay2(  {
      :m2_command => "discretize(#{datafiles_string}, #{discretized_datafiles_string}, #{p_value})",
      :m2_file => "Discretize.m2",
      :m2_wait => 1
    });
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
