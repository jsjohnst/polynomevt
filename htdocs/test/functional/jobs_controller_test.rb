require 'test_helper'

class JobsControllerTest < ActionController::TestCase 
  @@my_delayed_pid = nil
   
  # called before every single test 
  def setup 
    # make sure files directory is there
    `mkdir -p public/files`
    
    # make sure this directory exists otherwise the delayed_job server fails
    `mkdir -p tmp/pids`
    
    # start up our delayed_job server and/or kill an existing one first
    unless @@my_delayed_pid
      if FileTest.exists?("tmp/pids/delayed_job.pid")
        puts "killing existing delayed_job server"
        pid = `cat tmp/pids/delayed_job.pid`
        `kill #{pid}`
        count = 0;
        until `ps ax | grep delayed_job | grep -v grep`.length < 1
          puts "Waiting on delayed_job server to quit..."
          sleep(1)
          count = count + 1;
          if count > 5
            puts "trying to kill again"
            `killall delayed_job`
          end
        end
      end
      puts "starting delayed_job server"
      `ruby script/delayed_job -e test -n 1 start`
      @@my_delayed_pid = `cat tmp/pids/delayed_job.pid`
    end
  end
  
  def teardown  
    ## TODO maybe want to kill delayed_job? ...
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
    my_job = Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
      :input_data => "# First time course from testing\n1.2 2.3 3.4\n1.1 1.2 1.3\n2.2 2.3 2.4\n0.1 0.2 0.3\n" })
    assert my_job.save
    assert Delayed::Job.enqueue(ComputationJob.new(my_job.id))
    until my_job.completed? do
      print "|"
      sleep(1)
      my_job.reload
    end
    #puts "|"
    discretized_file_name = "public/" + my_job.file_prefix + ".discretized_input.txt"
    assert FileTest.exists?(discretized_file_name)

    # make sure file content is what we expect
    expected_data = ["#TS1", "0 1 1 ", "0 0 0 ", "1 1 1 ", "0 0 0 "]
    compare_content(discretized_file_name, expected_data)
  end

  test "should destroy job" do
    assert_difference('Job.count', -1) do
      delete :destroy, :id => jobs(:one).to_param
    end

    assert_redirected_to jobs_path
  end


  def compare_content(file_name, expected_data)
    my_file = File.open( file_name, "r")
    for data in expected_data do 
      line = my_file.gets
      line = line.chop
      assert_equal( data, line)
    end
  end
end
