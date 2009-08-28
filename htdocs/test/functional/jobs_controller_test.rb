require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  
  # called before every single test 
  def setup 
    # make sure files directory is there
    `mkdir -p public/files`
    running_processes = `ps ax | grep delayed_job | grep -v "grep" | wc -l`
    unless running_processes.to_i >= 1
      puts "starting delayed_job server"
      `mkdir -p tmp/pids`
      `ruby script/delayed_job -e development -n 2 start`
    end
  end
  
  def teardown  
    ## TODO maybe want to kill delayed_job ...
#    unless @job.file_prefix.nil?
#        prefix = "public/" + @job.file_prefix
#        `rm -r #{prefix}* 2> /dev/null`
#    end
  end


  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job" do
    assert_difference('Job.count') do
      post :create, :job => { :user_id => 2, :nodes => 3, :pvalue => 2 }
    end

    assert_redirected_to job_path(assigns(:job))
  end

  test "should show job" do
    get :show, :id => jobs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => jobs(:one).to_param
    assert_response :success
  end

  test "should update job" do
    put :update, :id => jobs(:one).to_param, :job => { :user_id => 1, :nodes => 5, :pvalue => 2, :update_schedule => "1 2 3 4 5" }
    assert_redirected_to job_path(assigns(:job))
  end

  test "should create file with discretized data" do
    assert !FileTest.exists?("public/discretized_input.txt")
    post :create,  :job => { :user_id => 1, :nodes => 3, :pvalue => 2,
      :input_data => "# First time course from testing\n 1.2  2.3  3.4\n 1.1  1.2
      1.3\n 2.2  2.3  2.4\n 0.1  0.2  0.3\n" }
    my_job = Job.find(jobs(:simple).to_param)
    until my_job.completed? do 
      sleep(1)
      puts ":"
      my_job = Job.find(my_job.id)
    end
    assert FileTest.exists?("public/" + my_job.file_prefix + ".discretized_input.txt")
  end

  test "should destroy job" do
    assert_difference('Job.count', -1) do
      delete :destroy, :id => jobs(:one).to_param
    end

    assert_redirected_to jobs_path
  end
end
