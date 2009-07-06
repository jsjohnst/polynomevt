module Macaulay
  # run a Macaulay job via M2
  def macaulay2(options = {})
    # available params:
    #
    # options.m2_file
    # options.m2_command
    # options.post_m2_command
    # options.m2_options
    # options.m2_script_path
    # options.m2_wait
    
    # TODO: Make sure m2_file actually exists
    if(!options[:m2_file] || !options[:m2_command])
      return;
    end
    
    # if no m2 options are provided, then default to sane defaults
    if(!options[:m2_options]) 
      options[:m2_options] = " --no-debug --silent -q -e "; 
    end
    
    # if no script path is provided, then default to sane defaults
    if(!options[:m2_script_path]) 
      options[:m2_script_path] = "macaulay2/"; 
    end

    # fork a background task to run M2
    spawn_id = spawn do
      # TODO: Check the return value of M2 and handle errors
      logger.info "cd #{options[:m2_script_path]}; M2 #{options[:m2_file]} #{options[:m2_options]} \"#{options[:m2_command]}; exit 0;\" >> ./macaulay.log 2>&1; cd ..;"
      
      `cd #{options[:m2_script_path]}; M2 #{options[:m2_file]} #{options[:m2_options]} \"#{options[:m2_command]}; exit 0;\" >> ./macaulay.log 2>&1; cd ..;`;
      if(options[:post_m2_command])
        `#{options[:post_m2_command]}`;
      end
    end
    
    if(options[:m2_wait])
      logger.info "Fixing to wait for M2 to complete as requested"
      wait(spawn_id);
    else
      logger.info "Returning immediately without waiting for M2 to finish"
    end
  end
  
  # format a ruby array into an M2 string
  def make_m2_string_from_array(filenames) 
    # if M2 begins with capitol letter it's considered a constant
    # we want a variable, thus why it's lower case
    m2_string = "{";
    first = 1;
    filenames.each { |filename|
      if(!first)
        m2_string += ",";
      end
      first = 0;
      m2_string += "///" + filename + "///";
    }
    m2_string += "}";
    return m2_string;
  end
  
  # a shorter synonym for make_m2_string_from_array
  def m2_string(filenames)
    make_m2_string_from_array(filenames)
  end
end