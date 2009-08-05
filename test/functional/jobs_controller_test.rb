require 'test_helper'

## Tests are run in alphabetical order
class JobsControllerTest < ActionController::TestCase

  # called before every single test 
  def setup 
    # make sure files directory is there
    `touch public/perl/files/`
    @job = jobs(:one)
  end
  
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  def teardown  
    unless @job.file_prefix.nil?
        prefix = "public/perl/" + @job.file_prefix
        `rm -r #{prefix}* 2> /dev/null`
    end
  end

   test "should create dummy job" do 
    assert_difference('Job.count') do 
        get :index 
    end
    print jobs(:one).input_data 
    print jobs(:one).to_s
    assert_response :success
   end
  
  # check prefix.done.js until var done = 1
  def wait_until_completed(prefix)  
    done_file = prefix + ".done.js"
    line = ""
    waiting = true
    while (waiting)
        File.open(done_file, 'r')  do |file| 
            line = file.gets 
        end

        assert line.match( /^var\sdone\s=\s/ ), message = "1st line in done.js did not match var"
        if line.match( /^var\sdone\s=\s1/ )
            #print "line did not match var done = 1"
            waiting = false
        elsif line.match( /^var\sdone\s=\s2/ )
           print "\nDone file matches file var = 2 (an error was printed to done
           file)\n"
           return false
        else
            sleep 1 
        end
    end
    true
  end

  def run_test_on_job( job, filename_list )
    JobsController.new.generate_output_of(job)
    @prefix = "public/perl/" + job.file_prefix

    wait_until_completed( @prefix )
    filename_list.each do |filename|  
        file = @prefix + filename
        assert  FileTest.exists?(file), "#{file} does not exist"
        assert  !FileTest.exists?("#{file}.dummy"), "#{file}.dummy does not exist"
    end
  end

  test "should upload input.txt" do
    run_test_on_job( @job, ".input.txt" )
  end
  
  test "should discretize data " do
    run_test_on_job( @job, ".discretized-input.txt" )
  end
  
  test "should generate wiring diagram" do
    @job.wiring_diagram = true
    run_test_on_job( @job, ".wiring-diagram." + @job.wiring_diagram_format )
  end
  
  test "should generate function file" do
    @job.show_functions = true
    run_test_on_job( @job, ".functionfile.txt" )
  end

  test "should generate state space" do
    @job.state_space = true
    run_test_on_job( @job, ".out." + @job.state_space_format )
  end
  
  test "should generate all files" do
    @job.show_discretized = true
    @job.wiring_diagram = true
    @job.show_functions = true
    @job.state_space = true
    run_test_on_job( @job, [ ".discretized-input.txt", ".wiring-diagram." +
    @job.wiring_diagram_format, ".functionfile.txt", ".out." + @job.state_space_format] )
  end
  


 test "should upload input.txt for deterministic network" do
    @job.is_deterministic = true
    run_test_on_job( @job, ".input.txt" )
  end
  
  test "should discretize data for deterministic network" do
    @job.is_deterministic = true 
    run_test_on_job( @job, ".discretized-input.txt" )
  end
  
  test "x should generate wiring diagram for deterministic network but I think we
  need to fix this bug" do
    @job.wiring_diagram = true
    @job.is_deterministic = true 
    run_test_on_job( @job, ".wiring-diagram." + @job.wiring_diagram_format )
  end
  
  test "should generate function file for deterministic network" do
    @job.show_functions = true
    @job.is_deterministic = true 
    run_test_on_job( @job, ".functionfile.txt" )
  end

  test "should generate function file with n lines for deterministic network" do
    @job.show_functions = true
    @job.is_deterministic = true 
    run_test_on_job( @job, ".functionfile.txt" )
    function_file = @prefix + ".functionfile.txt"
    number_of_functions = `wc -l < #{function_file}`
    assert_equal( @job.nodes, number_of_functions.chop.to_i )
  end

  test "should generate state space for deterministic network" do
    @job.state_space = true
    @job.is_deterministic = true 
    run_test_on_job( @job, ".out." + @job.state_space_format )
  end
  
  test "should generate all files for deterministic network" do
    @job.show_discretized = true
    @job.wiring_diagram = true
    @job.show_functions = true
    @job.state_space = true
    @job.is_deterministic = true 
    run_test_on_job( @job, [ ".discretized-input.txt", ".wiring-diagram." +
    @job.wiring_diagram_format, ".functionfile.txt", ".out." + @job.state_space_format] )
    assert wait_until_completed( @prefix ), "this should work without errors"
  end
  
 ############ update sequential ############ 
  
  test "should not allow stochastic model with sequential update" do
    @job = jobs(:stochastic_with_sequential)
    JobsController.new.generate_output_of(@job)
    @prefix = "public/perl/" + @job.file_prefix
    assert !wait_until_completed( @prefix ), "generate should have returned an error"
  end
 
 test "should upload input.txt for random sequential network" do
    @job.is_deterministic = true
    @job.sequential = true
    run_test_on_job( @job, ".input.txt" )
  end
  
  test "should discretize data for random sequential network" do
    @job.is_deterministic = true 
    @job.sequential = true
    run_test_on_job( @job, ".discretized-input.txt" )
  end
  
  test "should generate wiring diagram for random sequential network but I think we
  need to fix this bug" do
    @job.wiring_diagram = true
    @job.is_deterministic = true 
    @job.sequential = true
    run_test_on_job( @job, ".wiring-diagram." + @job.wiring_diagram_format )
  end
  
  test "should generate function file for random sequential network" do
    @job.show_functions = true
    @job.is_deterministic = true 
    @job.sequential = true
    run_test_on_job( @job, ".functionfile.txt" )
  end

  test "should generate function file with at least n lines for random sequential network" do
    @job.show_functions = true
    @job.is_deterministic = true 
    @job.sequential = true
    run_test_on_job( @job, ".functionfile.txt" )
    function_file = @prefix + ".functionfile.txt"
    number_of_functions = `wc -l < #{function_file}`
    assert( @job.nodes <= number_of_functions.chop.to_i )
  end

  test "should generate state space for random sequential network" do
    @job.state_space = true
    @job.is_deterministic = true 
    @job.sequential = true
    run_test_on_job( @job, ".out." + @job.state_space_format )
  end
  
  test "should generate all files for random sequential network" do
    @job.show_discretized = true
    @job.wiring_diagram = true
    @job.show_functions = true
    @job.state_space = true
    @job.is_deterministic = true 
    @job.sequential = true
    run_test_on_job( @job, [ ".discretized-input.txt", ".wiring-diagram." +
    @job.wiring_diagram_format, ".functionfile.txt", ".out." + @job.state_space_format] )
    assert wait_until_completed( @prefix ), "this should work without errors"
  end
  
  
  



#  test "should not generate this file" do 
#    assert !run_test_on_job( @job, "not-existing-file" )
#  end

end
