require 'test_helper'

class SimpleUserJobInteractionTest < ActionController::IntegrationTest
  fixtures :all

  test "Should register user and create job" do
    get "/"
    assert_redirected_to :action => :authenticate, :controller => :users
    
    post "/users/register", :user => { :login => "integration_login", :password => "integration_password" }
    assert_redirected_to :action => "profile", :controller => "users"
    
    data_file = fixture_file_upload('files/data.txt','text/plain')
    assert_difference('Job.count') do
      post "/jobs/create", :job => { :nodes => 3, :pvalue => 2, :input_file => data_file }
    end
  end
  
  test "Should try to create job, get redirected to login, then authenticate, then actual job creation" do
    get "/jobs/new"
    assert_redirected_to :action => :authenticate, :controller => :users
    
    my_user = users(:valid_user)
    post "/users/authenticate", :user => { :login => my_user.login, :password => my_user.password }
    assert_redirected_to :action => "new", :controller => "jobs"
    
    data_file = fixture_file_upload('files/data.txt','text/plain')
    assert_difference('Job.count') do
      post "/jobs/create", :job => { :nodes => 3, :pvalue => 2, :input_file => data_file }
    end
    
    assert_redirected_to jobs_path
  end
  
  test "Should show existing jobs for logged in user" do
    get "/jobs"
    assert_redirected_to :action => :authenticate, :controller => :users
    
    my_user = users(:one)
    post "/users/authenticate", :user => { :login => my_user.login, :password => my_user.password }
    assert_redirected_to :action => "index", :controller => "jobs"

    get "/jobs"
    assert_response :success
    assert_not_nil assigns(:jobs)
  end
  
  test "Deleting user should remove jobs associated with user" do
    my_user = User.find(1)
    num_jobs = Job.find(:all, :conditions => { :user_id => 1 }).length
    assert_difference('Job.count', -1 * num_jobs) do
      my_user.destroy
    end
  end
end
