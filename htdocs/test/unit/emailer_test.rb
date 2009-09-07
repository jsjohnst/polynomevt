require 'test_helper'

class EmailerTest < ActionMailer::TestCase
  tests Emailer
  
  def setup
    ActionMailer::Base.delivery_method = :test
  end
  
  test "test credential delivery" do
    email = Emailer.deliver_credentials("fhinkel@vt.edu", "test_login", "test_password")
    assert !ActionMailer::Base.deliveries.empty?

    # Test the body of the sent email contains what we expect it to
    assert_equal ["fhinkel@vt.edu"], email.to
    assert_equal "Polynome - Lost credentials information", email.subject
    assert_match /Login: test_login/, email.body
    assert_match /Password: test_password/, email.body
  end
end
