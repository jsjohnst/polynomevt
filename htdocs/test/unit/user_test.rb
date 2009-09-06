require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should not save invalid user" do 
    my_user = users(:invalid_user_without_login)
    assert !my_user.save, "should not save user without login"
    my_user = users(:invalid_user_with_invalid_email)
    assert !my_user.save, "should not save user with invalid email"
  end 

  test "should save simple user" do 
    my_user = users(:valid_user)
    assert my_user.valid?
    assert my_user.save, "should save this user, or not?"
  end

  test "should not save user with too short login" do 
    my_user = users(:invalid_login)
    assert !my_user.valid?
  end

  test "should not allow duplicate email addresses" do 
    my_user1 = User.new({ :login => "simpleuserfirst",
      :password => "simpleuserspassword",
      :email => "doubletwo@address.com",
      :first_name => "Double",
      :last_name => "User"})
    assert my_user1.save, "first user should have been saved" 
    my_user2 = User.new({ :login => "simpleusersecond",
      :password => "simpleuserspassword",
      :email => "doubletwo@address.com",
      :first_name => "Double",
      :last_name => "User"})
    assert !my_user2.save, "second user with same email address should not have been saved"
  end
  
  test "should allow two users with empty email address" do
    my_user1 = User.new({ :login => "firstwithoutemail",
      :password => "simpleuserspassword",
      :first_name => "First",
      :last_name => "User"})
    assert my_user1.save, "first user without email address should have been saved" 
    my_user2 = User.new({ :login => "secondwithoutemail",
      :password => "simpleuserspassword",
      :first_name => "Second",
      :last_name => "User"})
    assert my_user2.save, "second user without email address should have been saved"
    
    my_user1 = User.new({ :login => "firstwithoutemailempty",
      :password => "simpleuserspassword",
      :first_name => "First",
      :last_name => "User", :email => ""})
    assert my_user1.save, "first user with empty email address should have been saved" 
    my_user2 = User.new({ :login => "secondwithoutemailempty",
      :password => "simpleuserspassword",
      :first_name => "Second",
      :last_name => "User", :email => ""})
    assert my_user2.save, "second user with empty email address should have been saved"

    my_user1 = User.new({ :login => "firstwithoutemail1",
      :password => "simpleuserspassword"})
    assert my_user1.save, "first user without email address or name should have been saved" 
    my_user2 = User.new({ :login => "secondwithoutemail1",
      :password => "simpleuserspassword"})
    assert my_user2.save, "second user without email address or name should have been saved"
  end

end
