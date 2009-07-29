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

  test "generate 1" do
    job = jobs(:one)
    result = JobsController.new.generate_output_of(job)
    input_data = "public/perl/" + job.file_prefix + ".input.txt"
    assert  FileTest.exists?(input_data), "#{input_data} does not exist"
    not_existing_file = "dummy.txt"
    assert !FileTest.exists?(not_existing_file), "#{input_data} should not exist"

    
    #testFileExists "public/perl/"
    #check that generate completed
    #check the existence of certain files
    #for some of the files, use diff to test them.
    
      #assert_response :success
      #post :generate, :job => { :nodes => "3", :input_data=> "1 0 0
      #1 0 0 
      #0 1 1" }
  end

end
