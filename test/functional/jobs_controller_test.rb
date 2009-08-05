require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
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
        else
            sleep 1 
        end
    end
    
  end

  def run_test_on_job( job, filename )
    result = JobsController.new.generate_output_of(job)
    prefix = "public/perl/" + job.file_prefix

    wait_until_completed( prefix )
    file = prefix + filename
    assert  FileTest.exists?(file), "#{file} does not exist"
    assert  !FileTest.exists?("#{file}.dummy"), "#{file}.dummy does not exist"
    `rm -r #{prefix}*`
  end

  test "should upload input.txt" do
    job = jobs(:one)
    run_test_on_job( job, ".input.txt" )
  end
  
  test "should discretize data " do
    job = jobs(:one)
    run_test_on_job( job, ".discretized-input.txt" )
  end
  
  test "should generate wiring diagram" do
    job = jobs(:one)
    job.wiring_diagram = true
    run_test_on_job( job, ".wiring-diagram" + job.wiring_diagram_format )
  end
  
  test "should generate function file" do
    job = jobs(:one)
    job.show_functions = true
    run_test_on_job( job, ".functionfile.txt" )
  end

  test "should generate state space" do
    job = jobs(:one)
    job.state_space = true
    run_test_on_job( job, ".out" + job.state_space_format )
  end

end
