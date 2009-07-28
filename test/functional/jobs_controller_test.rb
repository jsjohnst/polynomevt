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

  test "should create job" do
      post :generate
      #assert_response :success
      #post :generate, :job => { :nodes => "3", :input_data=> "1 0 0
      #1 0 0 
      #0 1 1" }
  end

end
