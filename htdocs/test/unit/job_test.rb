require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "create simple job and save it" do 
    my_job = Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2,
    :update_schedule => "1 2 3 4 5"} )
    assert my_job.save
    
    assert Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2} ).save
  end

  test "should not create job with too many/few nodes" do
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 2}).save
    assert !Job.new({ :user_id => 1, :nodes => 12, :pvalue => 2}).save
    assert !Job.new({ :user_id => 1, :nodes => 0, :pvalue => 2}).save
    assert !Job.new({ :user_id => 1, :nodes => -1000, :pvalue => 2}).save
  end
  
  test "should create job with between 1-11 nodes" do
    assert Job.new({ :user_id => 1, :nodes => 1, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 2, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 4, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 6, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 7, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 8, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 9, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 10, :pvalue => 2}).save
    assert Job.new({ :user_id => 1, :nodes => 11, :pvalue => 2}).save
  end

  test "should not create job with pvalue other than two" do 
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 17}).save
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 1}).save
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 3}).save
  end
  
  test "should not create job with pvalue not integer" do 
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 'hello'}).save
  end
  
  test "should not create job without pvalue" do 
    assert !Job.new({ :user_id => 1, :nodes => 1000}).save
  end

  test "should not create job with nodes not valid integer" do 
    assert !Job.new({ :user_id => 1, :nodes => 'bye bye', :pvalue => 2}).save
  end
 
  test "should create job with show statespace and show functions" do 
    assert Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
    :show_state_space => true, :show_functions => true}).save
  end
  test "should not create job with show statespace but not functions" do 
    assert !Job.new(  { :user_id => 1, :nodes => 3, :pvalue => 2,
    :show_state_space => true, :show_functions => false}).save
  end

  test "should not create job with invalid update schedule" do 
  end

  test "should not create state space for stochastic job with too many nodes" do 
  end

  test "should not create stochastic job with sequential updates" do 
  end

  test "should allow large number of nodes if not simulated" do 
  end
end
