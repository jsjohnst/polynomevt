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
  
  test "should upload input.txt" do
    job = jobs(:one)
    result = JobsController.new.generate_output_of(job)
    sleep 4
    prefix = "public/perl/" + job.file_prefix
    input_data = prefix + ".input.txt"
    assert  FileTest.exists?("#{input_data}"), "#{input_data} does not exist"
    done_file = prefix + ".done.js"
    line = ""
    File.open(done_file, 'r')  do |file| 
        line = file.gets 
    end
    unless line.match( /^var\sdone\s=\s/ )
        print "line did not match var"
    end
    #unless line.match( /^var\sdone\s=\s0/ )
    #    print "line did not match var done = 0"
    #end
    unless line.match( /^var\sdone\s=\s1/ )
        print "line did not match var done = 1"
    end
    #`rm public/perl/#{job.file_prefix}*`
  end

  test "generate 1" do
    job = jobs(:one)
    result = JobsController.new.generate_output_of(job)

    print "about to sleep"
    sleep 4
    print "done sleeping"

    input_data = "public/perl/" + job.file_prefix + ".input.txt"
    assert  FileTest.exists?(input_data), "#{input_data} does not exist"
    not_existing_file = "dummy.txt"
    assert !FileTest.exists?(not_existing_file), "#{input_data} should not exist"
    newfiles = `ls public/perl/#{job.file_prefix}*`
    print newfiles
    #testFileExists "public/perl/"
    #check that generate completed
    #check the existence of certain files
    #for some of the files, use diff to test them.
    
      #1 0 0 
      #0 1 1" }
  end

end
