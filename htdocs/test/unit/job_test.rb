require 'test_helper'

class JobTest < ActiveSupport::TestCase
  test "create simple job and save it" do 
    my_job = Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2,
    :update_schedule => "1 2 3 4 5", :input_data => "3 2 1\n2 1 1\n1 1 0" } )
    assert my_job.save
    
    assert Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2, :input_data => "3 2 1\n2 1 1\n1 1 0" } ).save
  end

  test "should not create job with too many/few nodes" do
    for i in [1000, 12, 0, -1000] do 
      assert !Job.new({ :user_id => 1, :nodes => i, :pvalue => 2, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    end
  end
  
  test "should create job with between 1-11 nodes" do
    for i in 1 .. 11 do 
      assert Job.new({ :user_id => 1, :nodes => i, :pvalue => 2, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    end
  end

  test "should not create job with pvalue other than two" do 
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 17, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 1, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 3, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end
  
  test "should not create job with pvalue not integer" do 
    assert !Job.new({ :user_id => 1, :nodes => 1000, :pvalue => 'hello', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end
  
  test "should not create job without pvalue" do 
    assert !Job.new({ :user_id => 1, :nodes => 1000, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end

  test "should not create job with nodes not valid integer" do 
    assert !Job.new({ :user_id => 1, :nodes => 'bye bye', :pvalue => 2, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end
 
  test "should create job with show statespace and show functions" do 
    assert Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
    :show_state_space => true, :show_functions => true, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end
  test "should not create job with show statespace but not functions" do 
    assert !Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
    :show_state_space => true, :show_functions => false, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end

  test "should create job with empty update schedule" do 
    assert Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
      :update_schedule => '  ', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end

  test "should not create job with invalid update schedule" do 
    assert !Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
      :update_schedule => '1 4', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    assert !Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
      :update_schedule => '1 2 1', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save, "we need to fix this, 1 2 1 should not be allowed as valid update schedule"
    assert !Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
      :update_schedule => '1 2 3 4', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    assert !Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2,
      :update_schedule => 'invalid schedule', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end

  test "should not create state space for stochastic job with too many nodes" do 
    assert !Job.new({ :user_id => 1, :nodes => 11, :pvalue => 2,
      :make_deterministic_model => false, :show_state_space => true, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    assert !Job.new({ :user_id => 1, :nodes => 50, :pvalue => 2,
      :make_deterministic_model => false, :show_state_space => true, :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end

  test "should not create stochastic job with sequential updates" do 
    assert !Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2,
      :make_deterministic_model => false, :update_type => 'sequential', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
    assert !Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2,
      :make_deterministic_model => false, :update_type => 'sequential',
      :update_schedule => '1 2 3 4 5', :input_data => "3 2 1\n2 1 1\n1 1 0" }).save
  end

  test "should allow large number of nodes if not simulated" do 
    assert !Job.new({ :user_id => 1, :nodes => 5, :pvalue => 2, :input_data => "3 2 1\n2 1 1\n1 1 0", 
      :make_deterministic_model => false, :update_type => 'sequential'}).save
  end
  
  test "should not create job without input data" do
    assert !Job.new({ :user_id => 1, :nodes => 3, :pvalue => 2 }).save
  end
end
