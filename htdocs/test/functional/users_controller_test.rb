require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should redirect index to profile" do
    get :index
    assert_redirected_to :action => :profile
  end
  
  test "should get authenticate" do
    get :authenticate
    assert_response :success
  end
  
  test "should authenticate with login/password" do
    my_user = users(:valid_user)
    post :authenticate, :user => { :login => my_user.login, :password => my_user.password }
    assert_redirected_to :action => :profile
  end
  
  test "should not authenticate with bad login/password" do
    my_user = users(:valid_user)
    post :authenticate, :user => { :login => my_user.login, :password => "thisisaninvalidpassword" }
    assert_response :success
  end
  
  test "should redirect to previous page after successful login" do
    session[:intended_action] = :index
    session[:intended_controller] = :jobs
    
    my_user = users(:valid_user)
    post :authenticate, :user => { :login => my_user.login, :password => my_user.password }
    assert_redirected_to :action => :index, :controller => :jobs
  end
  
  test "should logout user" do
    my_user = users(:valid_user)
    post :authenticate, :user => { :login => my_user.login, :password => my_user.password }
    assert_redirected_to :action => :profile
    user_id = session[:user]
    get :logout
    assert session[:user] != user_id
    assert_nil session[:user]
    assert_redirected_to :action => :authenticate
  end
  
  test "should get register" do
    get :register
    assert_response :success
  end
  
  test "should register user" do
    assert_difference('User.count') do
      post :register, :user => { :login => "anothersimpleuserfirst", :password => "simpleuserspassword"}
    end
    assert_redirected_to :action => :profile
  end

  test "should not register user with duplicate login" do
    assert_difference('User.count') do
      post :register, :user => { :login => "anothersimpleuserfirst", :password => "simpleuserspassword"}
    end
    assert_redirected_to :action => :profile
    
    assert_no_difference('User.count') do
      post :register, :user => { :login => "anothersimpleuserfirst", :password => "simpleuserspassword"}
    end
    assert_response :success
    
  end
  
  test "should show profile if logged in" do
    session[:user] = 1
    get :profile
    assert_response :success
    assert_not_nil assigns(:user)
  end
  
  test "should not show profile if not logged in" do
    get :profile
    assert_redirected_to :action => :authenticate
  end

  test "should update user" do
    put :update, :id => users(:one).to_param, :user => { :login => "user", :password => "fubarbaz" }
    assert_redirected_to :action => :profile
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:two).to_param
    end

    assert_redirected_to :action => :authenticate
  end
end
