require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should not save invalid user" do 
    my_user = users(:invalid_user_without_login)
    assert !my_user.save, "should not save user without login"
    my_user = users(:invalid_user_with_invalid_email)
    assert !my_user.save, "should not save user with invalid email"
  end 

  test "should save simple user" do 
    my_user = users(:valid_user)
    assert my_user.save
  end

  test "should not allow duplicate email addresses" do 
    my_user1 = users(:valid_user_with_email_address)
    assert my_user1.save, "first user should have been saved" 
    my_user2 = users(:valid_user_with_double_email_address)
    assert !my_user2.save, "second user with same email address should not
    have been saved"
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => { :login => "useronlywithpassword", :password => "fubarbaz" }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, :id => users(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => users(:one).to_param
    assert_response :success
  end

  test "should update user" do
    put :update, :id => users(:one).to_param, :user => { :login => "user", :password => "fubarbaz" }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:two).to_param
    end

    assert_redirected_to users_path
  end
end
