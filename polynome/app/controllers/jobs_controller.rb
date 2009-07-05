require 'digest/md5'

include Spawn
include Macauley

class JobsController < ApplicationController
  layout "main"

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

    datafiles = self.split_data_into_files(params[:job][:input_data]);
        
    discretized_datafiles = [];
    datafiles.each { |datafile|
      discretized_datafiles.push(datafile.gsub(/input/, 'discretized-input'));
    }
    
    self.discretize_data(datafiles, discretized_datafiles, @p_value);
    self.generate_wiring_diagram(discretized_datafiles,
    @job.wiring_diagram_format, @p_value, @job.nodes);
    

    
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
  
  def discretize_data(datafiles, discretized_datafiles, p_value)    
    datafiles_string = make_m2_string_from_array(datafiles);
    discretized_datafiles_string = make_m2_string_from_array(discretized_datafiles);
    
    macauley_opts = {};
    macauley_opts[:m2_command] = 'discretize( ' + datafiles_string + ', ' + 
        discretized_datafiles_string + ', ' + p_value + ' )';
    macauley_opts[:m2_file] = "Discretize.m2";
    macauley_opts[:m2_wait] = 1;
    macauley2(macauley_opts);
  end
  
  def generate_wiring_diagram(discretized_datafiles, file_format, p_value, n_nodes)
    dotfile = "public/perl/" + @file_prefix + ".wiring-diagram.dot";
    graphfile = "public/perl/" + @file_prefix + ".wiring-diagram." + file_format;

    datafiles_string = make_m2_string_from_array(discretized_datafiles);
    logger.info "Datafiles: " + datafiles_string;
    
    macauley_opts = {};
    macauley_opts[:m2_command] = 'wd( ' + datafiles_string + ', \"../' + dotfile + 
        '\",  ' + p_value + ', ' + n_nodes.to_s + ' )';
    macauley_opts[:m2_file] = "wd.m2";
    macauley_opts[:post_m2_command] = "dot -T" + file_format + " -o " + graphfile + " " + dotfile;
    macauley2(macauley_opts);
  end
  def minsets_generate_wiring_diagram(discretized_data_files, file_format, p_value, n_nodes)
    dotfile = "public/perl/" + @file_prefix + ".wiring-diagram.dot";
    graphfile = "public/perl/" + @file_prefix + ".wiring-diagram." + file_format;
    datafiles_string = make_m2_string_from_array(discretized_data_files);
    
    macauley_opts = {};
    macauley_opts[:m2_command] = 'minsetsWD( ' + datafiles_string + ', \"../' + dotfile + 
        '\",  ' + p_value.to_s + ', ' + n_nodes.to_s + ' )';
    macauley_opts[:m2_file] = "minsets-web.m2";
    macauley_opts[:post_m2_command] = "dot -T" + file_format + " -o " + graphfile + " " + dotfile;
    macauley2(macauley_opts);
  end
  def generate_wiring_diagram(discretized_data_files, file_format, p_value, n_nodes)
    dotfile = "public/perl/" + @file_prefix + ".wiring-diagram.dot";
    graphfile = "public/perl/" + @file_prefix + ".wiring-diagram." + file_format;
    datafiles_string = make_m2_string_from_array(discretized_data_files);
    
    macauley_opts = {};
    macauley_opts[:m2_command] = 'wd( ' + datafiles_string + ', \"../' + dotfile + 
        '\",  ' + p_value + ', ' + n_nodes.to_s + ' )';
    macauley_opts[:m2_file] = "wd.m2";
    macauley_opts[:post_m2_command] = "dot -T" + file_format + " -o " + graphfile + " " + dotfile;
    macauley2(macauley_opts);
  end
  def is_data_consistent(discretized_data_files, p_value, n_nodes)
    function_file= "public/perl/" + @file_prefix + ".consistent.txt";
    datafiles_string = make_m2_string_from_array(discretized_data_files);
    
    macauley_opts = {};
    macauley_opts[:m2_command] = 'isConsistent( ' + datafiles_string + ', '  +
    p_value.to_s + ', ' + n_nodes.to_s + ' )';
    macauley_opts[:m2_file] = "isConsistent.m2";
    return macauley2(macauley_opts);
  end
  def sgfan(discretized_data_files, p_value, n_nodes)
    functionfile = "public/perl/" + @file_prefix + ".functionfile.txt";
    datafiles_string = make_m2_string_from_array(discretized_data_files);
    
    macauley_opts = {};
    macauley_opts[:m2_command] = 'sgfan( ' + datafiles_string + ', \"../' +
    functionfile + '\",  ' + p_value + ', ' + n_nodes.to_s + ' )';
    macauley_opts[:m2_file] = "func.m2";
    macauley2(macauley_opts);
  end
  def minsets(discretized_data_files, file_format, p_value, n_nodes)
    functionfile = "public/perl/" + @file_prefix + ".functionfile.txt";
    datafiles_string = make_m2_string_from_array(discretized_data_files);
    
    macauley_opts = {};
    macauley_opts[:m2_command] = 'minsets( ' + datafiles_string + ', \"../' +
    functionfile + '\",  ' + p_value + ', ' + n_nodes.to_s + ' )';
    macauley_opts[:m2_file] = "minsets-web.m2";
    macauley2(macauley_opts);
  end
end
